---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating custom subagents, built-in agents (Explore, Plan, general-purpose), frontmatter fields, model selection, tool restrictions, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagent definitions.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for creating and using subagents in Claude Code.

## Quick Reference

### What Are Subagents?

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them to offload tasks that would flood your main conversation with output you won't need again.

**Built-in subagents** (auto-invoked by Claude):

| Agent | Model | Tools | When used |
| :--- | :--- | :--- | :--- |
| Explore | Haiku | Read-only | File search and codebase exploration |
| Plan | Inherits | Read-only | Context-gathering during plan mode |
| General-purpose | Inherits | All | Complex multi-step tasks and modifications |
| statusline-setup | Sonnet | — | When you run `/statusline` |
| Claude Code Guide | Haiku | — | When you ask about Claude Code features |

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` dir | Where plugin is enabled | 5 (lowest) |

Higher-priority definitions override lower-priority ones with the same name.

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific,
actionable feedback on quality, security, and best practices.
```

### Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools the subagent can use; inherits all if omitted |
| `disallowedTools` | No | Denylist of tools to remove from inherited or specified set |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent (ignored for plugin subagents) |
| `hooks` | No | Lifecycle hooks scoped to this subagent (ignored for plugin subagents) |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | Set `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | Set `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session |

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first; a tool in both is removed.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits in working directory / `additionalDirectories` |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only exploration mode |

If the parent uses `bypassPermissions` or `acceptEdits`, those take precedence. If the parent uses `auto`, the subagent inherits auto mode and `permissionMode` in frontmatter is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

When memory is enabled, the subagent gets instructions to maintain `MEMORY.md` (first 200 lines / 25 KB loaded at startup). Read, Write, and Edit tools are automatically enabled.

### Invoke Subagents

```text
# Natural language (Claude decides)
Use the code-reviewer subagent to review my recent changes

# @-mention (guarantees that subagent runs)
@"code-reviewer (agent)" look at the auth changes

# Run whole session as a subagent
claude --agent code-reviewer

# Set as default in .claude/settings.json
{ "agent": "code-reviewer" }
```

For plugin subagents: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### CLI-Defined Subagents (Session Only)

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

### Restrict Which Subagents Can Be Spawned

```yaml
tools: Agent(worker, researcher), Read, Bash
```

This is an allowlist — only `worker` and `researcher` can be spawned. Use `Agent` (no parens) to allow all. Omit `Agent` entirely to block spawning. Only applies when running as main thread with `claude --agent`.

To deny specific subagents globally:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

### Hooks in Subagent Frontmatter

Hooks defined in frontmatter run only while that subagent is active:

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

Project-level hooks in `settings.json` can also respond to `SubagentStart` and `SubagentStop` events.

### Scope MCP Servers to a Subagent

```yaml
mcpServers:
  # Inline (scoped to this subagent only)
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name (reuses existing session connection)
  - github
```

### Foreground vs. Background

- **Foreground**: blocks main conversation; permission prompts pass through
- **Background**: runs concurrently; permissions pre-approved before launch, then auto-denied if missing
- Press **Ctrl+B** to background a running task, or ask Claude to "run this in the background"
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks

### Forked Subagents (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+).

A fork inherits the full conversation history, system prompt, tools, and model from the main session — no re-explaining needed. Use it when a named subagent would need too much background.

```text
/fork draft unit tests for the parser changes so far
```

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt/tools | Same as main session | From definition file |
| Prompt cache | Shared with main session | Separate cache |
| Permissions | Prompts surface in terminal | Pre-approved before launch |

A fork cannot spawn further forks.

### Fork Panel Keys

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork transcript / send follow-up |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

### Common Patterns

- **Isolate high-volume operations**: delegate test runs, log parsing, doc fetching to a subagent so verbose output stays out of your main context
- **Parallel research**: spawn multiple subagents for independent investigations; Claude synthesizes results
- **Chain subagents**: use one subagent to find issues, pass results to another to fix them
- **Subagents cannot spawn other subagents** — chain from the main conversation instead

### When to Use Subagents vs. Main Conversation

Use **subagents** when:
- The task produces verbose output you don't need in main context
- You want to enforce specific tool restrictions or permissions
- The work is self-contained and can return a summary

Use the **main conversation** when:
- Frequent back-and-forth or iterative refinement is needed
- Multiple phases share significant context
- Latency matters (subagents start fresh and gather context)

Consider **Skills** instead when you want reusable prompts that run in the main conversation context.

### Resume a Subagent

Each invocation creates a fresh instance. To continue prior work:
```text
Use the code-reviewer subagent to review the authentication module
[Agent completes]
Continue that code review and now analyze the authorization logic
```

Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and persist independently of the main conversation (cleaned up after `cleanupPeriodDays`, default 30 days).

### Auto-Compaction

Subagents compact at ~95% context capacity (same logic as the main conversation). Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, creating subagents via `/agents` or files, all frontmatter fields, model selection, tool control, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
