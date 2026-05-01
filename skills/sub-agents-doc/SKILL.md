---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents (Explore/Plan/general-purpose), creating custom subagents, frontmatter fields, tool access control, permission modes, persistent memory, hooks, forked subagents, explicit invocation, foreground/background execution, and common patterns.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. They keep verbose output out of the main conversation and return only a summary.

### Built-in subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherits | All | Complex multi-step tasks needing exploration + action |
| statusline-setup | Sonnet | — | Invoked by `/statusline` to configure status line |
| Claude Code Guide | Haiku | — | Answers questions about Claude Code features |

### Subagent scope and priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Supported frontmatter fields

Only `name` and `description` are required.

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools the subagent can use; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools to remove from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or reference by name) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session agent |

Note: `hooks`, `mcpServers`, and `permissionMode` are ignored for plugin subagents.

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool access control

Use `tools` (allowlist) or `disallowedTools` (denylist). If both are set, `disallowedTools` is applied first, then `tools` is resolved against the remaining pool.

To restrict which subagents can be spawned (when running as main thread via `--agent`), use `Agent(name)` syntax in `tools`:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

Use `Agent` without parentheses to allow spawning any subagent without restrictions.

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working directory |
| `auto` | Background classifier reviews commands and protected writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode — read-only exploration |

If the parent uses `bypassPermissions` or `acceptEdits`, this takes precedence and cannot be overridden by the subagent.

### Persistent memory scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not in version control |

When memory is enabled, the subagent's system prompt includes instructions for reading/writing to the memory directory and the first 200 lines or 25KB of `MEMORY.md`.

### Hook events for subagents

**Frontmatter hooks** (run while the subagent is active):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**settings.json hooks** (lifecycle events in main session):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking subagents

| Method | Effect |
| :--- | :--- |
| Natural language (name the subagent) | Claude decides whether to delegate |
| `@agent-<name>` (or `@"<name> (agent)")` | Guarantees the named subagent runs for one task |
| `claude --agent <name>` | Whole session uses that subagent's system prompt/tools/model |
| `agent` key in `.claude/settings.json` | Default for every session in the project |

### Foreground vs background subagents

- **Foreground**: blocks main conversation until complete; permission prompts pass through
- **Background**: runs concurrently; permissions pre-approved before launch; auto-denies anything not pre-approved

Press Ctrl+B to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely.

### Disable specific subagents

Add to `permissions.deny` in `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or use `--disallowedTools "Agent(Explore)"` CLI flag.

### Forked subagents (experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+). A fork inherits the entire conversation history, system prompt, tools, and model from the main session. Use `/fork <directive>` to start one manually.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt/tools | Same as main session | From definition file |
| Prompt cache | Shared with main session | Separate cache |
| Permissions | Prompts surface in terminal | Pre-approved before launch |

### Common patterns

- **Isolate high-volume operations**: delegate test runs, log processing, or doc fetching to keep verbose output out of main context
- **Parallel research**: spawn multiple subagents for independent investigations
- **Chain subagents**: use subagents in sequence for multi-step workflows
- **Resuming subagents**: ask Claude to "continue that work" — it uses `SendMessage` with the agent's ID (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

### When to use subagents vs main conversation

Use **main conversation** when: frequent back-and-forth is needed, multiple phases share significant context, or latency matters.

Use **subagents** when: the task produces verbose output, you want to enforce tool restrictions, or the work is self-contained.

Use **Skills** instead when you want reusable prompts that run in the main conversation context.

Subagents cannot spawn other subagents. Nesting requires Skills or chaining from the main conversation.

### CLI flag for session-scoped subagents

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer...",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

The `--agents` flag accepts the same fields as frontmatter (`prompt` replaces the markdown body).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, all frontmatter fields, tool access control, permission modes, persistent memory, hooks, fork mode, invocation patterns, and example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
