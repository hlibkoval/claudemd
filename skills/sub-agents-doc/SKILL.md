---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents (Explore, Plan, general-purpose), creating and configuring custom subagents, frontmatter fields, model selection, tool access, permission modes, persistent memory, hooks, forked subagents, invocation patterns (@-mention, --agent flag), foreground/background execution, context management, and example subagents.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Are Subagents?

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use one when a side task would flood your main conversation with output you won't reference again — the subagent does the work in isolation and returns only a summary.

### Built-in Subagents

| Subagent | Model | Tools | When Claude uses it |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration (skips CLAUDE.md and git status) |
| **Plan** | Inherits | Read-only | Codebase research during plan mode (skips CLAUDE.md and git status) |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring both exploration and action |
| **statusline-setup** | Sonnet | — | When you run `/statusline` |
| **claude-code-guide** | Haiku | — | When you ask about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

Subagents are Markdown files with YAML frontmatter. The body becomes the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. When invoked, analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier using lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before subagent stops |
| `skills` | No | Skills to preload into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary isolated git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session |

Note: `hooks`, `mcpServers`, and `permissionMode` are ignored for plugin subagents.

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
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, that takes precedence and cannot be overridden.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When memory is enabled, the first 200 lines or 25KB of `MEMORY.md` is included in the subagent's context. Read, Write, and Edit tools are automatically enabled.

### Hooks for Subagents

**In subagent frontmatter** (scoped to that subagent only):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** (main session, reacts to subagent lifecycle):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Syntax | Effect |
| :--- | :--- | :--- |
| Natural language | `Use the code-reviewer subagent to…` | Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)" look at changes` | Guarantees that subagent runs for one task |
| Session-wide | `claude --agent code-reviewer` | Whole session uses that subagent's prompt, tools, and model |
| Project default | `"agent": "code-reviewer"` in `.claude/settings.json` | Default for every session in the project |

For plugin subagents, use scoped names: `@agent-my-plugin:code-reviewer` or `claude --agent my-plugin:security-reviewer`.

### Foreground vs. Background

- **Foreground**: Blocks the main conversation; permission prompts pass through.
- **Background**: Runs concurrently; auto-denies any tool call that would otherwise prompt.

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks.

### Disabling Specific Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Restricting Which Subagents a Main Agent Can Spawn

Use `Agent(name)` syntax in the `tools` field of an agent running via `--agent`:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

To allow spawning any subagent without restriction, use `Agent` without parentheses. Subagents themselves cannot spawn other subagents.

### What Loads at Subagent Startup

A non-fork subagent receives:
- Its own system prompt (markdown body or `prompt` field)
- The task delegation message from Claude
- CLAUDE.md files and memory hierarchy (except Explore and Plan, which skip these)
- Git status snapshot (except Explore and Plan)
- Any skills listed in the `skills` frontmatter field

### Fork Mode (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+). A fork inherits the full conversation history and system prompt instead of starting fresh. Use `/fork <directive>` to spawn a fork manually.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with the delegation prompt |
| System prompt and tools | Same as main session | From the subagent's definition file |
| Model | Same as main session | From the subagent's `model` field |
| Prompt cache | Shared with main session | Separate cache |

### CLI-Defined Subagents

Pass JSON with `--agents` for session-only subagents (not saved to disk):

```bash
claude --agents '{"code-reviewer": {"description": "...", "prompt": "...", "tools": ["Read", "Grep"], "model": "sonnet"}}'
```

### Common Patterns

| Pattern | When to use |
| :--- | :--- |
| **Isolate high-volume ops** | Run tests, fetch docs, process logs — verbose output stays in subagent context |
| **Run parallel research** | Independent investigations across multiple codebase areas simultaneously |
| **Chain subagents** | Multi-step workflows where each step hands results to the next |

### When to Use Subagents vs. Other Approaches

| Tool | Use when |
| :--- | :--- |
| **Subagent** | Task produces verbose output; self-contained work; tool restrictions needed |
| **Main conversation** | Frequent back-and-forth; multiple phases sharing context; quick targeted change |
| **Skills** | Reusable prompts or workflows running in the main conversation context |
| **`/btw`** | Quick question about something already in context; no tool access needed |
| **Agent teams** | Sustained parallelism; tasks exceeding context window; teammates need to communicate |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, full configuration options, working with subagents, fork mode, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
