---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating and configuring custom subagents, frontmatter fields, built-in subagents, tool access, permission modes, persistent memory, hooks, fork mode, and working patterns.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### Built-in Subagents

| Agent             | Model   | Tools          | Purpose                                               |
| :---------------- | :------ | :------------- | :---------------------------------------------------- |
| Explore           | Haiku   | Read-only      | File discovery, code search, codebase exploration     |
| Plan              | Inherit | Read-only      | Codebase research during plan mode                    |
| general-purpose   | Inherit | All tools      | Complex research, multi-step operations, modifications |
| statusline-setup  | Sonnet  | —              | Invoked by `/statusline` command                      |
| claude-code-guide | Haiku   | —              | Answers Claude Code feature questions                 |

### Subagent Scope and Priority

| Location                     | Scope                   | Priority    | Create via                                    |
| :--------------------------- | :---------------------- | :---------- | :-------------------------------------------- |
| Managed settings             | Organization-wide       | 1 (highest) | Deployed via managed settings                 |
| `--agents` CLI flag          | Current session only    | 2           | Pass JSON when launching Claude Code          |
| `.claude/agents/`            | Current project         | 3           | Interactive (`/agents`) or manual             |
| `~/.claude/agents/`          | All your projects       | 4           | Interactive (`/agents`) or manual             |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest)  | Installed with plugins                        |

### Supported Frontmatter Fields

| Field             | Required | Description                                                                                                                      |
| :---------------- | :------- | :------------------------------------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier: lowercase letters and hyphens                                                                                 |
| `description`     | Yes      | When Claude should delegate to this subagent                                                                                     |
| `tools`           | No       | Allowlist of tools. Inherits all tools if omitted. Use `Agent(name)` syntax to restrict which subagents can be spawned          |
| `disallowedTools` | No       | Denylist applied before `tools` resolves; if both set, denied tools are removed first                                           |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default)                                                                |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents                       |
| `maxTurns`        | No       | Maximum agentic turns before stopping                                                                                            |
| `skills`          | No       | Skills to preload into context at startup (full content injected)                                                                |
| `mcpServers`      | No       | MCP servers for this subagent. Inline definition or string reference. Ignored for plugin subagents                               |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents                                                            |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                                                          |
| `background`      | No       | `true` to always run as a background task (default: `false`)                                                                     |
| `effort`          | No       | Effort override: `low`, `medium`, `high`, `xhigh`, `max`                                                                        |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (auto-cleaned if no changes made)                                                  |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                                          |
| `initialPrompt`   | No       | Auto-submitted as first user turn when agent runs as main session (via `--agent`). Commands and skills are processed             |

### Model Resolution Order

When Claude invokes a subagent, the model is resolved in this order:

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Mode Behavior

| Mode                | Behavior                                                                                              |
| :------------------ | :---------------------------------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                                             |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands for working dir / `additionalDirectories`       |
| `auto`              | Background classifier reviews commands and protected-directory writes                                 |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)                                    |
| `bypassPermissions` | Skip all permission prompts (use with caution; rm -rf / still prompts as circuit breaker)             |
| `plan`              | Plan mode (read-only exploration)                                                                     |

If parent uses `bypassPermissions` or `acceptEdits`, these take precedence and cannot be overridden. If parent uses auto mode, subagent inherits it and any `permissionMode` in frontmatter is ignored.

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                                     |
| :-------- | :-------------------------------------------- | :----------------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<agent-name>/`        | Learnings should persist across all projects                 |
| `project` | `.claude/agent-memory/<agent-name>/`          | Knowledge is project-specific and shareable via git          |
| `local`   | `.claude/agent-memory-local/<agent-name>/`    | Knowledge is project-specific but NOT for version control    |

When memory is enabled: system prompt includes memory instructions + first 200 lines or 25KB of `MEMORY.md`; Read, Write, and Edit are automatically enabled.

### Hook Events for Subagents

#### In subagent frontmatter (run while subagent is active)

| Event         | Matcher input | When it fires                                                     |
| :------------ | :------------ | :---------------------------------------------------------------- |
| `PreToolUse`  | Tool name     | Before the subagent uses a tool                                   |
| `PostToolUse` | Tool name     | After the subagent uses a tool                                    |
| `Stop`        | (none)        | When the subagent finishes (converted to `SubagentStop` at runtime) |

#### In `settings.json` (run in main session)

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invocation Methods

| Method          | Syntax                                           | Effect                                                        |
| :-------------- | :----------------------------------------------- | :------------------------------------------------------------ |
| Natural language | Name the subagent in your prompt               | Claude typically delegates                                    |
| @-mention        | `@"agent-name (agent)"` or `@agent-<name>`     | Guarantees that subagent runs for the task                    |
| CLI flag         | `claude --agent <name>`                         | Whole session uses the subagent's system prompt and tools     |
| Settings default | `"agent": "name"` in `.claude/settings.json`   | Default agent for every session in the project                |
| List agents      | `claude agents`                                 | Lists all configured agents grouped by source                 |

### Fork Mode (Experimental)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (requires v2.1.117+).

|                         | Fork                             | Named subagent                          |
| :---------------------- | :------------------------------- | :-------------------------------------- |
| Context                 | Full conversation history        | Fresh context with prompt you pass      |
| System prompt and tools | Same as main session             | From subagent's definition file         |
| Model                   | Same as main session             | From subagent's `model` field           |
| Permissions             | Prompts surface in terminal      | Pre-approved before launch, auto-denied after |
| Prompt cache            | Shared with main session         | Separate cache                          |

Fork panel keyboard controls:

| Key       | Action                                                            |
| :-------- | :---------------------------------------------------------------- |
| `↑` / `↓` | Move between rows                                                 |
| `Enter`   | Open fork's transcript and send follow-up messages                |
| `x`       | Dismiss a finished fork or stop a running one                     |
| `Esc`     | Return focus to prompt input                                      |

### When to Use Subagents vs. Alternatives

| Use case                                              | Recommendation                     |
| :---------------------------------------------------- | :--------------------------------- |
| Verbose output (test runs, logs, fetched docs)        | Subagent — keeps noise out of main context |
| Enforce tool restrictions or permission isolation     | Subagent                           |
| Self-contained task with summary output               | Subagent                           |
| Frequent back-and-forth / iterative refinement        | Main conversation                  |
| Multiple phases sharing significant context           | Main conversation                  |
| Quick targeted change or low-latency work             | Main conversation                  |
| Reusable prompts running in main conversation context | Skills                             |
| Quick side question with full context, no tools       | `/btw`                             |
| Sustained parallelism or context exceeds window       | Agent teams                        |

### Disable Specific Subagents

In `settings.json`:
```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Context and Transcript Storage

- Transcripts stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Subagent transcripts persist independently of main conversation compaction
- Auto-compaction triggers at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Cleanup based on `cleanupPeriodDays` setting (default: 30 days)
- `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` disables all background task functionality

### Plugin Subagent Restrictions

Plugin subagents do NOT support these frontmatter fields (they are silently ignored):
- `hooks`
- `mcpServers`
- `permissionMode`

To use these fields, copy the agent file into `.claude/agents/` or `~/.claude/agents/`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Full guide to creating, configuring, and working with subagents including built-in agents, frontmatter reference, patterns, fork mode, and examples

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
