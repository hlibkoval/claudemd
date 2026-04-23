---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating custom subagents, built-in subagents, frontmatter configuration fields, tool control, permission modes, persistent memory, hooks, invocation patterns, and common usage patterns.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them to keep verbose output out of your main conversation, enforce tool constraints, and route work to faster or cheaper models.

### Built-in subagents

| Subagent          | Model    | Tools        | When Claude uses it                              |
| :---------------- | :------- | :----------- | :----------------------------------------------- |
| **Explore**       | Haiku    | Read-only    | Searching and analyzing codebases                |
| **Plan**          | Inherits | Read-only    | Research during plan mode before presenting plan |
| **General-purpose** | Inherits | All          | Complex multi-step tasks needing exploration and action |
| statusline-setup  | Sonnet   | —            | When you run `/statusline`                       |
| Claude Code Guide | Haiku    | —            | Questions about Claude Code features             |

### Subagent scope and priority

| Location                     | Scope             | Priority    |
| :--------------------------- | :---------------- | :---------- |
| Managed settings             | Organization-wide | 1 (highest) |
| `--agents` CLI flag          | Current session   | 2           |
| `.claude/agents/`            | Current project   | 3           |
| `~/.claude/agents/`          | All your projects | 4           |
| Plugin's `agents/` directory | Plugin scope      | 5 (lowest)  |

### Supported frontmatter fields

| Field             | Required | Description                                                                                          |
| :---------------- | :------- | :--------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier using lowercase letters and hyphens                                                |
| `description`     | Yes      | When Claude should delegate to this subagent                                                         |
| `tools`           | No       | Allowlist of tools the subagent can use; inherits all tools if omitted                               |
| `disallowedTools` | No       | Denylist of tools to remove from inherited or specified list                                         |
| `model`           | No       | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default: `inherit`)                        |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                         |
| `maxTurns`        | No       | Maximum number of agentic turns before the subagent stops                                            |
| `skills`          | No       | Skills to inject into the subagent's context at startup (not inherited from parent)                  |
| `mcpServers`      | No       | MCP servers available to the subagent (inline definitions or references to configured servers)       |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                              |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                              |
| `background`      | No       | Set to `true` to always run as a background task (default: `false`)                                  |
| `effort`          | No       | Effort level: `low`, `medium`, `high`, `xhigh`, `max` (overrides session effort)                    |
| `isolation`       | No       | Set to `worktree` to run in an isolated temporary git worktree                                       |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`              |
| `initialPrompt`   | No       | Auto-submitted as first user turn when agent runs as main session (via `--agent` or `agent` setting) |

### Model resolution order

When Claude invokes a subagent, the model is resolved in this priority order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter passed by Claude
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission modes

| Mode                | Behavior                                                                               |
| :------------------ | :------------------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                              |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands in working directory              |
| `auto`              | Background classifier reviews commands and protected-directory writes                  |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)                     |
| `bypassPermissions` | Skip all permission prompts (use with caution)                                         |
| `plan`              | Read-only exploration (plan mode)                                                      |

If the parent uses `bypassPermissions` or `acceptEdits`, that takes precedence and cannot be overridden by the subagent.

### Persistent memory scopes

| Scope     | Location                                          | Use when                                                     |
| :-------- | :------------------------------------------------ | :----------------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<agent-name>/`            | Learnings apply across all projects                          |
| `project` | `.claude/agent-memory/<agent-name>/`              | Project-specific knowledge, shareable via version control    |
| `local`   | `.claude/agent-memory-local/<agent-name>/`        | Project-specific knowledge, not checked into version control |

When enabled, the subagent's system prompt includes memory directory instructions and the first 200 lines / 25 KB of `MEMORY.md`. Read, Write, and Edit tools are automatically enabled.

### Tool control patterns

```yaml
# Allowlist: only these tools
tools: Read, Grep, Glob, Bash

# Denylist: everything except these
disallowedTools: Write, Edit

# Restrict which subagents can be spawned (only when running as main session)
tools: Agent(worker, researcher), Read, Bash
```

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first.

### Hooks in subagent frontmatter

| Event         | When it fires                                       |
| :------------ | :-------------------------------------------------- |
| `PreToolUse`  | Before the subagent uses a tool                     |
| `PostToolUse` | After the subagent uses a tool                      |
| `Stop`        | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Project-level hooks for subagent lifecycle events

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invoking subagents explicitly

| Method          | Behavior                                                                   |
| :-------------- | :------------------------------------------------------------------------- |
| Natural language | Name the subagent; Claude decides whether to delegate                      |
| `@agent-<name>` | Guarantees that specific subagent runs for one task                        |
| `--agent <name>` CLI flag | Whole session uses that subagent's system prompt, tools, and model |
| `"agent"` in `.claude/settings.json` | Project-wide default agent for every session          |

### Disabling specific subagents

In `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Foreground vs background subagents

- **Foreground**: blocks main conversation; permission prompts and questions pass through to user
- **Background**: runs concurrently; permissions approved upfront; `AskUserQuestion` tool calls fail silently
- Press **Ctrl+B** to background a running task, or ask Claude to "run this in the background"
- Disable all background tasks: set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### When to use subagents vs main conversation

Use **subagents** when:
- The task produces verbose output you don't need in main context
- You want to enforce specific tool restrictions or permissions
- The work is self-contained and can return a summary

Use the **main conversation** when:
- The task needs frequent back-and-forth or iterative refinement
- Multiple phases share significant context
- Latency matters (subagents start fresh)

### Common patterns

| Pattern               | Example prompt                                                                        |
| :-------------------- | :------------------------------------------------------------------------------------|
| Isolate high-volume   | "Use a subagent to run the test suite and report only failing tests"                 |
| Parallel research     | "Research auth, database, and API modules in parallel using separate subagents"      |
| Chain subagents       | "Use code-reviewer to find issues, then use optimizer to fix them"                   |
| Resume a subagent     | Ask Claude to "continue" after a subagent finishes — it re-uses the prior context   |

### Subagent transcript location

Transcripts: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

Auto-compaction triggers at ~95% context capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

### Limitations

- Subagents **cannot spawn other subagents**
- Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` frontmatter fields
- Subagents do **not** inherit skills from the parent conversation — list them explicitly in `skills`
- The `skills` and `mcpServers` subagent frontmatter fields are NOT applied when running as an agent-teams teammate

### Best practices

- Write a clear, specific `description` — Claude uses it to decide when to delegate
- Add "use proactively" in the description to encourage automatic delegation
- Limit tool access to only what the subagent needs
- Check project subagents (`.claude/agents/`) into version control
- Design focused subagents: each should excel at one specific task

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, quickstart, configuration options, tool control, permission modes, skills preloading, persistent memory, hooks, invocation patterns, foreground/background execution, context management, auto-compaction, and example subagents.

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
