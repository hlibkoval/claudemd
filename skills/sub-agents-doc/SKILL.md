---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — built-in subagents, creating and configuring custom subagents, frontmatter fields, tool control, permission modes, hooks, persistent memory, forked subagents, invocation patterns, and example subagent definitions.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that handle specific tasks in their own context window. Each runs with a custom system prompt, scoped tool access, and independent permissions. Only its summary returns to the main conversation — keeping exploration output, logs, and verbose results out of your main context.

### Built-in subagents

| Subagent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration |
| **Plan** | Inherit | Read-only | Codebase research during plan mode |
| **General-purpose** | Inherit | All | Complex multi-step tasks requiring exploration and action |
| **statusline-setup** | Sonnet | — | Configure status line (via `/statusline`) |
| **Claude Code Guide** | Haiku | — | Answer questions about Claude Code features |

### Subagent scope and priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter fields

Only `name` and `description` are required. All others are optional.

| Field | Description |
| :--- | :--- |
| `name` | Unique identifier — lowercase letters and hyphens |
| `description` | When Claude should delegate to this subagent |
| `tools` | Allowlist of tools the subagent can use (inherits all if omitted) |
| `disallowedTools` | Tools to deny from the inherited or specified list |
| `model` | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default) |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | Max agentic turns before the subagent stops |
| `skills` | Skills to inject into the subagent's context at startup |
| `mcpServers` | MCP servers available to this subagent (inline or by reference name) |
| `hooks` | Lifecycle hooks scoped to this subagent |
| `memory` | Persistent memory scope: `user`, `project`, or `local` |
| `background` | Set to `true` to always run as a background task (default: `false`) |
| `effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | Set to `worktree` to run in a temporary git worktree |
| `color` | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | Auto-submitted as first user turn when agent runs as the main session |

### Model resolution order

When Claude invokes a subagent, the model is resolved in this order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool control

```yaml
# Allowlist — only these tools available:
tools: Read, Grep, Glob, Bash

# Denylist — inherit all except these:
disallowedTools: Write, Edit

# Restrict spawnable subagents (only when running as main thread via --agent):
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first.

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working dir or `additionalDirectories` |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts entirely |
| `plan` | Read-only exploration (plan mode) |

If the parent uses `bypassPermissions` or `acceptEdits`, that mode takes precedence and cannot be overridden by the subagent.

### Persistent memory scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but not for version control |

Memory enabled: subagent gets Read/Write/Edit automatically, and the first 200 lines or 25KB of `MEMORY.md` is injected into its system prompt.

### Hook events for subagents

**In subagent frontmatter** (active only while the subagent runs):

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** (main session lifecycle hooks):

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking subagents

| Method | Effect |
| :--- | :--- |
| Natural language ("use the X subagent to...") | Claude decides whether to delegate |
| `@"agent-name (agent)"` mention | Guarantees this subagent runs for one task |
| `claude --agent <name>` | Entire session runs as that subagent |
| `agent` key in `.claude/settings.json` | Default agent for every session in the project |

### Forked subagents (experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`. Requires Claude Code v2.1.117+.

A fork inherits the full conversation history instead of starting fresh. Use it when a named subagent would need too much background to be useful.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| **Context** | Full conversation history | Fresh context with the prompt you pass |
| **System prompt** | Same as main session | From the subagent's definition file |
| **Model** | Same as main session | From the subagent's `model` field |
| **Prompt cache** | Shared with main session | Separate cache |

With fork mode enabled: `/fork <directive>` spawns a fork; every subagent spawn runs in the background.

### Foreground vs background

- **Foreground**: blocks the main conversation; permission prompts pass through
- **Background**: runs concurrently; permissions are pre-approved before launch; auto-denies anything not pre-approved
- Press **Ctrl+B** to background a running task
- Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely

### When to use subagents vs main conversation

Use **subagents** when the task produces verbose output, needs tool restrictions, or is self-contained with a returnable summary.

Use the **main conversation** when the task needs frequent back-and-forth, multiple phases share context, or latency matters.

Use **Skills** instead when you want reusable prompts or workflows that run in the main conversation context.

Use `/btw` for quick side questions that don't need tool access and shouldn't be retained in history.

### Disable a subagent

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Subagent transcript storage

Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days). Auto-compaction triggers at ~95% capacity (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` to change threshold).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, quickstart, the `/agents` command, scope and priority, writing subagent files, all frontmatter fields, model selection, tool control, permission modes, skills preloading, persistent memory, hooks, disabling subagents, foreground vs background execution, common patterns, choosing between subagents and main conversation, context management, auto-compaction, forked subagents, and example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
