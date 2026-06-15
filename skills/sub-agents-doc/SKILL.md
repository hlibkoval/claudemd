---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents — how to create, configure, invoke, and manage specialized AI assistants that run in isolated context windows.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Fast codebase search and analysis. Skips CLAUDE.md and git status. |
| **Plan** | Inherits | Read-only | Research during plan mode. Skips CLAUDE.md and git status. |
| **general-purpose** | Inherits | All | Complex multi-step tasks needing both exploration and modification. |
| **statusline-setup** | Sonnet | — | Auto-invoked by `/statusline`. |
| **claude-code-guide** | Haiku | — | Auto-invoked when you ask about Claude Code features. |

Disable a built-in with `permissions.deny`: `["Agent(Explore)", "Agent(Plan)"]`. In non-interactive/SDK mode, set `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`.

### Subagent Scopes and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When names collide, the higher-priority location wins. Scopes are scanned recursively; identity comes from the `name` frontmatter field, not the filename.

### Subagent File Format

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

The markdown body becomes the system prompt. Only `name` and `description` are required.

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier using lowercase letters and hyphens. |
| `description` | Yes | When Claude should delegate to this subagent. |
| `tools` | No | Allowlist of tools. Inherits all if omitted. Use `Agent(type)` to restrict which subagents can be spawned. |
| `disallowedTools` | No | Denylist applied before `tools` allowlist. |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, a full model ID, or `inherit`. Defaults to `inherit`. |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin subagents. |
| `maxTurns` | No | Maximum agentic turns before the subagent stops. |
| `skills` | No | Skills to preload into the subagent's context at startup (full content injected). |
| `mcpServers` | No | MCP servers available to this subagent. Ignored for plugin subagents. |
| `hooks` | No | Lifecycle hooks scoped to this subagent. Ignored for plugin subagents. |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local`. |
| `background` | No | `true` to always run as a background task. Default: `false`. |
| `effort` | No | Effort override: `low`, `medium`, `high`, `xhigh`, `max`. |
| `isolation` | No | `worktree` to run in a temporary git worktree. |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`. |
| `initialPrompt` | No | Auto-submitted as the first user turn when running as the main session agent via `--agent`. |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands in the working directory |
| `auto` | Auto mode: background classifier reviews commands |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, this takes precedence and cannot be overridden. If the parent is in auto mode, the subagent inherits it and `permissionMode` in frontmatter is ignored.

### Persistent Memory

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not version-controlled |

When memory is enabled, the first 200 lines or 25KB of `MEMORY.md` is injected at startup. Read, Write, and Edit are automatically enabled.

### Tool Access Patterns

Allowlist (only these tools):
```yaml
tools: Read, Grep, Glob, Bash
```

Denylist (everything except these):
```yaml
disallowedTools: Write, Edit
```

Restrict spawnable sub-subagents (when running as main thread with `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```

### Hooks in Subagent Frontmatter

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

### Session-Level Hooks for Subagent Lifecycle

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Syntax | Behavior |
| :--- | :--- | :--- |
| Natural language | "Use the code-reviewer subagent to…" | Claude decides whether to delegate |
| @-mention | `@"code-reviewer (agent)" look at auth changes` | Guarantees that subagent runs for this task |
| Session-wide (CLI) | `claude --agent code-reviewer` | Main thread uses this subagent's prompt, tools, and model |
| Session-wide (settings) | `{ "agent": "code-reviewer" }` in `.claude/settings.json` | Default for every session in this project |

Plugin subagents appear in the typeahead as `my-plugin:code-reviewer`. Use `@agent-my-plugin:code-reviewer` to mention manually.

### Foreground vs Background

- **Foreground**: blocks the main conversation; permission prompts surface interactively.
- **Background**: runs concurrently; auto-denies any tool call that would prompt. Press **Ctrl+B** to background a running task.

Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background tasks.

### Forks

A fork is a subagent that inherits the full conversation history instead of starting fresh. Invoke with `/fork <directive>` (requires Claude Code v2.1.117+; enabled by default from v2.1.161).

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with delegated prompt |
| System prompt | Same as main session | From the subagent definition file |
| Model | Same as main session | From `model` field |
| Permissions | Prompts surface in terminal | Auto-denied when background |
| Prompt cache | Shared with main session | Separate cache |

Set `CLAUDE_CODE_FORK_SUBAGENT=1` to enable fork mode (general-purpose spawns become forks) or `=0` to disable. A fork cannot spawn another fork.

### What Loads at Startup (non-fork subagents)

| Content | Loaded? |
| :--- | :--- |
| Subagent's own system prompt + environment details | Always |
| Delegation task message | Always |
| CLAUDE.md and memory hierarchy | Yes, except Explore and Plan skip it |
| Git status snapshot from parent session start | Yes, except Explore and Plan skip it |
| Preloaded skills (from `skills` frontmatter) | Only if listed |

### Nested Subagents (v2.1.172+)

Subagents can spawn their own subagents. Foreground subagents can nest at any depth. Background subagents are capped at depth 5. To prevent a subagent from spawning others, omit `Agent` from its `tools` list.

### Resuming Subagents

Each invocation creates a new instance. To resume an existing subagent's work, ask Claude to continue it — it retains full conversation history. Explore and Plan cannot be resumed (no agent ID returned). Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

### CLI-Defined Subagents

Pass JSON to `--agents` for session-only subagents (not saved to disk). Uses `prompt` instead of a markdown body:

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

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Full guide: built-in agents, configuration, scopes, tool control, hooks, forks, context management, examples

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
