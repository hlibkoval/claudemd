---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents: creating and configuring custom subagents, built-in subagents, tool/permission control, hooks, persistent memory, forked subagents, and common patterns.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|:------|:------|:------|:--------|
| `Explore` | Haiku | Read-only | Fast codebase search; skips CLAUDE.md and git status |
| `Plan` | Inherits | Read-only | Research during plan mode; skips CLAUDE.md and git status |
| `general-purpose` | Inherits | All | Complex multi-step tasks requiring exploration + action |
| `statusline-setup` | Sonnet | — | Auto-used when you run `/statusline` |
| `claude-code-guide` | Haiku | — | Auto-used for Claude Code feature questions |

### Subagent Scope & Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

Subagent files are Markdown with YAML frontmatter. The body is the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens). Hooks receive this as `agent_type` |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted. Use `Agent(type)` to restrict spawning |
| `disallowedTools` | No | Tools to deny from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup (full content injected, not just descriptions) |
| `mcpServers` | No | MCP servers for this subagent (inline definitions or string references). Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, or `max`. Overrides session effort |
| `isolation` | No | `worktree` to run in an isolated git worktree |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session via `--agent` |

### Model Resolution Order

When Claude invokes a subagent, the model is resolved in this order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter from Claude
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** — only these tools available:
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** — inherit all except these:
```yaml
disallowedTools: Write, Edit
```

If both are set, `disallowedTools` is applied first, then `tools` resolves against what remains. A tool in both is removed.

**Restrict spawnable subagent types** (when running as main thread via `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```

Tools unavailable to subagents even when listed: `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, `WaitForMcpServers`.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits for paths in working dir or `additionalDirectories` |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden. If parent uses auto mode, the subagent inherits auto mode regardless of frontmatter.

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control (recommended default) |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into version control |

When memory is enabled, Read/Write/Edit tools are automatically added, and the first 200 lines or 25 KB of `MEMORY.md` is injected into the subagent's system prompt.

### Hooks in Subagent Frontmatter

Define hooks that run only while the subagent is active:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Project-Level Hooks for Subagent Lifecycle

Configure in `settings.json` to respond to subagent events in the main session:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents Explicitly

| Method | Description |
|:-------|:------------|
| Natural language | Name the subagent; Claude decides whether to delegate |
| `@agent-<name>` @-mention | Guarantees that specific subagent runs for one task |
| `claude --agent <name>` | Whole session uses the subagent's system prompt, tools, and model |
| `agent` in `.claude/settings.json` | Makes the agent the default for every session in a project |

For plugin subagents: `@agent-my-plugin:code-reviewer` or `claude --agent my-plugin:security-reviewer`.

### Foreground vs. Background

| Mode | Behavior |
|:-----|:---------|
| Foreground | Blocks main conversation; permission prompts surface to you |
| Background | Runs concurrently; auto-denies prompts that would require approval |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks.

### CLI-Defined Subagents (`--agents` flag)

Pass JSON when launching; agents exist for the session only and are not saved to disk:

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

### What Loads at Subagent Startup

| Content | Standard subagent | Explore / Plan |
|:--------|:-----------------|:---------------|
| Subagent's own system prompt | Yes | Yes |
| Task delegation message from Claude | Yes | Yes |
| CLAUDE.md and memory hierarchy | Yes | No |
| Git status snapshot | Yes | No |
| Preloaded skills (from `skills` field) | Yes | No (no built-in preloads) |
| Parent conversation history | No (fresh context) | No |

### Forked Subagents

A fork inherits the entire parent conversation instead of starting fresh.

| | Fork | Named subagent |
|:-|:-----|:---------------|
| Context | Full conversation history | Fresh context with the delegation prompt |
| System prompt and tools | Same as main session | From the subagent definition file |
| Model | Same as main session | From the subagent's `model` field |
| Permissions | Prompts surface in your terminal | Auto-denied when running in the background |
| Prompt cache | Shared with main session | Separate cache |

Start a fork manually with `/fork <directive>`. Requires Claude Code v2.1.117+; the `/fork` command is enabled by default from v2.1.161.

Set `CLAUDE_CODE_FORK_SUBAGENT=1` to make Claude use forks instead of the general-purpose subagent automatically (every subagent spawn then runs in the background).

A fork cannot spawn further forks.

### Disable Specific Subagents

Add to `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### When to Use Subagents vs. Main Conversation

Use **subagents** when:
- Task produces verbose output (test runs, log processing, doc fetches) you don't need in main context
- You want to enforce specific tool restrictions or permissions
- Work is self-contained and can return a summary

Use **main conversation** when:
- Task needs frequent back-and-forth or iterative refinement
- Multiple phases share significant context
- Making a quick targeted change
- Latency matters (subagents start fresh and gather context)

Consider **Skills** instead when you want reusable prompts or workflows that run in the main conversation context rather than isolated subagent context.

### Subagent Transcript Storage

Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) — Built-in subagents, quickstart, configuration options, tool/permission/hook/memory control, invoking subagents, foreground vs. background, forked subagents, and example subagent definitions

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
