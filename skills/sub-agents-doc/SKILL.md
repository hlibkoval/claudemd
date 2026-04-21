---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### Built-in Subagents

| Agent           | Model   | Tools                  | Purpose                                      |
| :-------------- | :------ | :--------------------- | :------------------------------------------- |
| Explore         | Haiku   | Read-only              | File discovery, code search, codebase exploration |
| Plan            | Inherit | Read-only              | Codebase research during plan mode           |
| General-purpose | Inherit | All                    | Complex multi-step tasks requiring exploration and action |
| statusline-setup | Sonnet | —                      | Configure status line via `/statusline`      |
| Claude Code Guide | Haiku | —                      | Answers questions about Claude Code features |

### Subagent Scope & Priority

| Location                     | Scope             | Priority    |
| :--------------------------- | :---------------- | :---------- |
| Managed settings             | Organization-wide | 1 (highest) |
| `--agents` CLI flag          | Current session   | 2           |
| `.claude/agents/`            | Current project   | 3           |
| `~/.claude/agents/`          | All projects      | 4           |
| Plugin's `agents/` directory | Plugin scope      | 5 (lowest)  |

### Frontmatter Fields

| Field             | Required | Description                                                                                      |
| :---------------- | :------- | :----------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens)                                                |
| `description`     | Yes      | When Claude should delegate to this subagent                                                     |
| `tools`           | No       | Allowlist of tools; inherits all if omitted                                                      |
| `disallowedTools` | No       | Denylist of tools removed from inherited or specified list                                       |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`)                     |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                     |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                                                  |
| `skills`          | No       | Skills to inject into subagent context at startup (full content, not just available)             |
| `mcpServers`      | No       | MCP servers for this subagent (inline definitions or string references)                          |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                          |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                          |
| `background`      | No       | `true` to always run as background task (default: `false`)                                       |
| `effort`          | No       | Effort level: `low`, `medium`, `high`, `xhigh`, `max`; overrides session effort                 |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (isolated copy of repo)                            |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`          |
| `initialPrompt`   | No       | Auto-submitted as first user turn when agent runs as main session via `--agent`                  |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode                | Behavior                                                                    |
| :------------------ | :-------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                   |
| `acceptEdits`       | Auto-accept file edits for paths in working directory / additionalDirectories |
| `auto`              | Background classifier reviews commands and protected-directory writes       |
| `dontAsk`           | Auto-deny permission prompts (allowed tools still work)                     |
| `bypassPermissions` | Skip permission prompts (caution: use sparingly)                            |
| `plan`              | Plan mode — read-only exploration                                           |

### Persistent Memory Scopes

| Scope     | Location                                      | Use when                                                    |
| :-------- | :-------------------------------------------- | :---------------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings apply across all projects                         |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via version control (recommended) |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked into version control          |

### Hook Events for Subagents

| Event           | Matcher input   | When it fires                       |
| :-------------- | :-------------- | :---------------------------------- |
| `PreToolUse`    | Tool name       | Before the subagent uses a tool     |
| `PostToolUse`   | Tool name       | After the subagent uses a tool      |
| `Stop`          | (none)          | When the subagent finishes (converted to `SubagentStop` at runtime) |
| `SubagentStart` | Agent type name | (settings.json) When a subagent begins execution |
| `SubagentStop`  | Agent type name | (settings.json) When a subagent completes        |

### Key Patterns

**Invoke a subagent:**
- Natural language: "Use the code-reviewer subagent to review my changes"
- @-mention: `@"code-reviewer (agent)"` — guarantees that subagent runs
- Session-wide: `claude --agent code-reviewer`
- Default in project: set `"agent": "code-reviewer"` in `.claude/settings.json`

**Disable specific subagents** via `permissions.deny` in settings.json:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-agent)"] } }
```

**Restrict spawnable subagents** using `Agent(type)` syntax in `tools`:
```yaml
tools: Agent(worker, researcher), Read, Bash
```

**Tool precedence:** if both `tools` and `disallowedTools` are set, `disallowedTools` is applied first, then `tools` resolves against the remaining pool.

**Subagents cannot spawn other subagents.** Use agent teams or chain from main conversation for nested delegation.

**Subagent transcripts** are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and cleaned up after `cleanupPeriodDays` (default: 30 days).

**Auto-compaction** triggers at ~95% context capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

**Plugin subagents** do not support `hooks`, `mcpServers`, or `permissionMode` frontmatter (ignored for security).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Complete guide to built-in and custom subagents, frontmatter fields, scope, tools, permissions, hooks, memory, and example subagent definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
