---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating custom subagents, frontmatter fields, tool and permission configuration, built-in subagents, scoping, hooks, persistent memory, forked subagents, and common patterns.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents (specialized AI assistants that handle specific tasks in isolated contexts).

## Quick Reference

### What Subagents Are For

Use a subagent when a side task would flood the main conversation with output you won't reference again. The subagent works in its own context window and returns only a summary.

Benefits: preserve context, enforce tool constraints, reuse configurations, specialize behavior, control costs (route to Haiku).

### Built-in Subagents

| Agent             | Model   | Tools                | When used                                         |
| :---------------- | :------ | :------------------- | :------------------------------------------------ |
| Explore           | Haiku   | Read-only            | File discovery, code search, codebase exploration |
| Plan              | Inherit | Read-only            | Codebase research during plan mode                |
| general-purpose   | Inherit | All tools            | Complex multi-step tasks needing exploration + action |
| statusline-setup  | Sonnet  | —                    | When you run `/statusline`                        |
| claude-code-guide | Haiku   | —                    | Questions about Claude Code features              |

### Subagent Scopes and Priority

| Location                     | Scope             | Priority    | Create via                            |
| :--------------------------- | :---------------- | :---------- | :------------------------------------ |
| Managed settings             | Organization-wide | 1 (highest) | Admin-deployed managed settings       |
| `--agents` CLI flag          | Current session   | 2           | JSON when launching Claude Code       |
| `.claude/agents/`            | Current project   | 3           | `/agents` or manual file              |
| `~/.claude/agents/`          | All your projects | 4           | `/agents` or manual file              |
| Plugin's `agents/` directory | Plugin scope      | 5 (lowest)  | Installed with plugin                 |

Higher-priority location wins when names conflict. Project agents (`.claude/agents/`) are checked into version control for team sharing.

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

The frontmatter configures the subagent; the body is its system prompt. Subagents receive only this system prompt — not the full Claude Code system prompt.

### Supported Frontmatter Fields

| Field             | Required | Description                                                                                              |
| :---------------- | :------- | :------------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier: lowercase letters and hyphens. Hooks receive this as `agent_type`                     |
| `description`     | Yes      | When Claude should delegate to this subagent                                                             |
| `tools`           | No       | Allowlist of tools; inherits all if omitted. Use `Agent(name)` to restrict spawnable subagents           |
| `disallowedTools` | No       | Denylist of tools removed from inherited or specified list                                               |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default)                                        |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin agents   |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                                                          |
| `skills`          | No       | Skills preloaded into context at startup (full content injected)                                         |
| `mcpServers`      | No       | MCP servers for this subagent (inline definitions or name references). Ignored for plugin agents         |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent. Ignored for plugin agents                                       |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                                  |
| `background`      | No       | `true` to always run as a background task (default: `false`)                                             |
| `effort`          | No       | Effort override: `low`, `medium`, `high`, `xhigh`, `max`                                                |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (isolated repo copy)                                      |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                  |
| `initialPrompt`   | No       | Auto-submitted as first user turn when agent runs as the main session (via `--agent` or `agent` setting) |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

Use `tools` (allowlist) or `disallowedTools` (denylist). If both set, `disallowedTools` applies first, then `tools` is resolved against the remaining pool.

Restrict which subagents an agent-as-main-thread can spawn using `Agent(worker, researcher)` syntax in `tools`. Omit `Agent` entirely to block all spawning.

### Permission Modes

| Mode                | Behavior                                                              |
| :------------------ | :-------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                             |
| `acceptEdits`       | Auto-accept file edits for paths in working dir or additionalDirs     |
| `auto`              | Background classifier reviews commands                                |
| `dontAsk`           | Auto-deny prompts (explicitly allowed tools still work)               |
| `bypassPermissions` | Skip all permission prompts (use with caution)                        |
| `plan`              | Plan mode (read-only exploration)                                     |

If parent uses `bypassPermissions` or `acceptEdits`, it takes precedence. If parent uses `auto`, subagent inherits auto mode and its `permissionMode` is ignored.

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                           |
| :-------- | :-------------------------------------------- | :------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`              | Knowledge applies across all projects              |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via version control    |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked into version control |

When enabled: system prompt includes memory instructions + first 200 lines/25KB of `MEMORY.md`; Read, Write, Edit tools auto-enabled.

### Hooks for Subagents

**In subagent frontmatter** (run while that subagent is active):

| Event         | When it fires                                                     |
| :------------ | :---------------------------------------------------------------- |
| `PreToolUse`  | Before the subagent uses a tool                                   |
| `PostToolUse` | After the subagent uses a tool                                    |
| `Stop`        | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** (main session lifecycle events):

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invoking Subagents

- **Natural language**: name the subagent in your prompt
- **@-mention**: `@"code-reviewer (agent)"` — guarantees that subagent runs for one task
- **Plugin agents**: `@agent-<plugin-name>:<agent-name>`
- **Session-wide**: `claude --agent code-reviewer` (replaces default system prompt)
- **Default in project**: set `"agent": "code-reviewer"` in `.claude/settings.json`

### Foreground vs Background

- **Foreground**: blocks main conversation; permission prompts surface to you
- **Background**: runs concurrently; auto-denies any tool call that would prompt
- Press Ctrl+B to background a running task
- Disable all background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Forked Subagents (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+).

A fork inherits the entire conversation history instead of starting fresh. Use when a named subagent would need too much background context.

| Aspect                  | Fork                           | Named subagent                    |
| :---------------------- | :----------------------------- | :-------------------------------- |
| Context                 | Full conversation history      | Fresh context with passed prompt  |
| System prompt and tools | Same as main session           | From subagent definition file     |
| Model                   | Same as main session           | From subagent `model` field       |
| Prompt cache            | Shared with main session       | Separate cache                    |

Start a fork: `/fork draft unit tests for the parser changes so far`

Fork panel keys: `↑`/`↓` move between rows, `Enter` opens fork transcript, `x` dismisses/stops, `Esc` returns focus.

### Subagent Context Management

- Each invocation creates a new instance with fresh context
- To resume: ask Claude to "continue" previous work; Claude uses `SendMessage` with the agent's ID
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Auto-compaction triggers at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Transcripts cleaned up based on `cleanupPeriodDays` setting (default: 30 days)

### Disable Specific Subagents

In settings.json:
```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Common Patterns

- **Isolate high-volume ops**: delegate test runs, log processing, doc fetching — verbose output stays in subagent context
- **Parallel research**: spawn multiple subagents for independent investigations simultaneously
- **Chain subagents**: use subagents in sequence for multi-step workflows
- **When to use main conversation instead**: frequent back-and-forth, shared context across phases, quick targeted changes, latency-sensitive work

### CLI-Defined Subagents

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

Accepts the same fields as frontmatter; `prompt` = system prompt body. Session-only, not saved to disk.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, creating subagents, all frontmatter fields, tool and permission control, hooks, persistent memory, foreground/background execution, forked subagents, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
