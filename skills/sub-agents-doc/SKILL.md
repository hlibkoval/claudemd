---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating, configuring, and managing specialized AI subagents with custom prompts, tool restrictions, permission modes, hooks, persistent memory, and model selection.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. They handle a task and return only the summary, keeping verbose output out of your main conversation. Subagents cannot spawn other subagents.

### Built-in subagents

| Subagent          | Model   | Tools            | Purpose                                      |
| :---------------- | :------ | :--------------- | :------------------------------------------- |
| **Explore**       | Haiku   | Read-only        | File discovery, code search, codebase exploration |
| **Plan**          | Inherit | Read-only        | Codebase research during plan mode           |
| **General-purpose** | Inherit | All tools       | Complex research, multi-step operations, code modifications |
| statusline-setup  | Sonnet  | —                | Configures status line via `/statusline`     |
| Claude Code Guide | Haiku   | —                | Answers questions about Claude Code features |

### Subagent file format

Markdown with YAML frontmatter for configuration, body becomes the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

### Supported frontmatter fields

| Field             | Required | Description                                                                                  |
| :---------------- | :------- | :------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens)                                            |
| `description`     | Yes      | When Claude should delegate to this subagent                                                 |
| `tools`           | No       | Tool allowlist; inherits all tools if omitted                                                |
| `disallowedTools` | No       | Tool denylist; removed from inherited or specified list                                      |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`)                  |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                  |
| `maxTurns`        | No       | Maximum agentic turns before subagent stops                                                  |
| `skills`          | No       | Skills injected into subagent context at startup (full content, not just availability)        |
| `mcpServers`      | No       | MCP servers: inline definitions or string references to already-configured servers            |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent (`PreToolUse`, `PostToolUse`, `Stop`)                 |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                       |
| `background`      | No       | `true` to always run as a background task (default: `false`)                                 |
| `effort`          | No       | Override session effort: `low`, `medium`, `high`, `xhigh`, `max`                             |
| `isolation`       | No       | `worktree` for an isolated git worktree copy; auto-cleaned if no changes                     |
| `color`           | No       | UI color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`               |
| `initialPrompt`   | No       | Auto-submitted first user turn when running as main session agent via `--agent`               |

### Subagent scope and priority

| Priority | Location                     | Scope               | Creation method           |
| :------- | :--------------------------- | :------------------- | :------------------------ |
| 1 (highest) | Managed settings          | Organization-wide    | Deployed via managed settings |
| 2        | `--agents` CLI flag          | Current session      | JSON when launching       |
| 3        | `.claude/agents/`            | Current project      | Interactive or manual     |
| 4        | `~/.claude/agents/`          | All your projects    | Interactive or manual     |
| 5 (lowest) | Plugin's `agents/` dir    | Where plugin enabled | Installed with plugins    |

When multiple subagents share the same name, the higher-priority location wins. Plugin subagents do NOT support `hooks`, `mcpServers`, or `permissionMode` fields.

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter (Claude's choice at delegation time)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool control

- **Allowlist** (`tools`): only these tools are available
- **Denylist** (`disallowedTools`): removed from inherited set
- If both are set: `disallowedTools` applied first, then `tools` resolved against remainder
- `Agent(worker, researcher)` syntax restricts which subagent types can be spawned (only for `--agent` main thread)

### Invoking subagents

| Method              | How                                                      | Behavior                                     |
| :------------------ | :------------------------------------------------------- | :------------------------------------------- |
| Automatic           | Claude decides based on `description` field              | Delegates when task matches description      |
| Natural language    | Name the subagent in your prompt                         | Claude typically delegates                   |
| @-mention           | `@"code-reviewer (agent)" review the auth changes`      | Guarantees subagent runs for this task        |
| Session-wide        | `claude --agent code-reviewer` or `"agent"` in settings | Entire session uses subagent's config        |

### Foreground vs background

| Mode       | Behavior                                                                     |
| :--------- | :--------------------------------------------------------------------------- |
| Foreground | Blocks main conversation; permission prompts pass through to user            |
| Background | Runs concurrently; permissions pre-approved upfront; auto-denies unapproved  |

Toggle: ask Claude to "run this in the background", press **Ctrl+B**, or set `background: true` in frontmatter. Disable all background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Persistent memory

| Scope     | Location                                      | Use when                                                |
| :-------- | :-------------------------------------------- | :------------------------------------------------------ |
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects              |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific, shareable via VCS        |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific but should not be committed            |

When enabled, the subagent's `MEMORY.md` (first 200 lines or 25KB) is loaded into context. Read, Write, and Edit tools are automatically enabled for memory management.

### Hooks for subagents

**In frontmatter** (run while subagent is active):

| Event         | Matcher   | Fires when                       |
| :------------ | :-------- | :------------------------------- |
| `PreToolUse`  | Tool name | Before subagent uses a tool      |
| `PostToolUse` | Tool name | After subagent uses a tool       |
| `Stop`        | (none)    | When subagent finishes (becomes `SubagentStop`) |

**In settings.json** (run in main session):

| Event           | Matcher         | Fires when                  |
| :-------------- | :-------------- | :-------------------------- |
| `SubagentStart` | Agent type name | Subagent begins execution   |
| `SubagentStop`  | Agent type name | Subagent completes          |

### Disabling subagents

Add to `permissions.deny` in settings:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Resuming subagents

Use `SendMessage` with the agent's ID (requires agent teams enabled via `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Resumed subagents retain full conversation history. Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

### Auto-compaction

Triggers at ~95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50`).

### When to use subagents vs alternatives

| Situation                                      | Use                                |
| :--------------------------------------------- | :--------------------------------- |
| Task produces verbose output                   | Subagent                           |
| Need tool restrictions or specific permissions  | Subagent                           |
| Self-contained work returning a summary         | Subagent                           |
| Frequent back-and-forth or iterative refinement | Main conversation                  |
| Quick question using existing context           | `/btw`                             |
| Reusable prompts in main conversation context   | Skills                             |
| Multiple agents needing inter-agent messaging   | Agent teams                        |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, quickstart with `/agents`, subagent file format and all frontmatter fields, scope and priority, model selection, tool control, MCP server scoping, permission modes, skills preloading, persistent memory, hooks, foreground/background execution, invocation patterns, resuming, auto-compaction, and example subagents.

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
