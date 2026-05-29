---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating and configuring custom subagents, built-in subagents, frontmatter fields, tool control, permission modes, hooks, persistent memory, fork mode, background/foreground execution, and example subagent patterns.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

### What Are Subagents?

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use one when a side task would flood your main conversation with output you won't reference again — the subagent does that work and returns only the summary.

Subagents work within a single session. For many independent parallel sessions, see agent teams (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Subagents **cannot** spawn other subagents.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Fast codebase search and analysis. Skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Research during plan mode. Skips CLAUDE.md and git status |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring exploration and action |
| **statusline-setup** | Sonnet | — | Auto-invoked by `/statusline` command |
| **claude-code-guide** | Haiku | — | Auto-invoked for Claude Code feature questions |

### Subagent Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When names conflict, higher priority wins. Both `.claude/agents/` and `~/.claude/agents/` are scanned recursively; subdirectory paths do not affect identity — only the `name` frontmatter field matters. Check project subagents into version control to share with your team.

### Supported Frontmatter Fields

Only `name` and `description` are required. All others are optional.

| Field | Description |
| :--- | :--- |
| `name` | Unique identifier using lowercase letters and hyphens |
| `description` | When Claude should delegate to this subagent |
| `tools` | Allowlist of tools the subagent can use. Omit to inherit all |
| `disallowedTools` | Denylist of tools to remove from inherited or specified set |
| `model` | `sonnet`, `opus`, `haiku`, a full model ID, or `inherit` (default) |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | Maximum agentic turns before the subagent stops |
| `skills` | Skills to preload into the subagent's context at startup |
| `mcpServers` | MCP servers available to this subagent (inline or by reference name) |
| `hooks` | Lifecycle hooks scoped to this subagent |
| `memory` | Persistent memory scope: `user`, `project`, or `local` |
| `background` | Set `true` to always run as a background task |
| `effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | Set `worktree` to run in a temporary git worktree |
| `color` | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | Auto-submitted as first user turn when agent runs as main session via `--agent` |

Note: `hooks`, `mcpServers`, and `permissionMode` are ignored for plugin subagents.

### Minimal Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific, actionable feedback.
```

The YAML body becomes the system prompt. Subagents receive only this prompt plus basic environment details — not the full Claude Code system prompt. Loaded from disk at session start; restart required for file edits (except changes via `/agents` which take effect immediately).

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** (restrict to only these tools):
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** (inherit all except these):
```yaml
disallowedTools: Write, Edit
```

If both are set, `disallowedTools` is applied first, then `tools` is resolved against the remainder.

Tools unavailable to subagents regardless of configuration: `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, `WaitForMcpServers`.

**Restrict which subagents can be spawned** (only applies when agent runs as main thread via `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```
Omit `Agent` entirely to prevent spawning any subagents. Use `Agent` without parentheses to allow spawning any subagent.

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits in working directory |
| `auto` | Background classifier reviews commands and protected writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts — use with caution |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden by the subagent. If the parent uses auto mode, the subagent inherits auto mode and its frontmatter `permissionMode` is ignored.

### Persistent Memory

```yaml
memory: user    # ~/.claude/agent-memory/<name>/
memory: project # .claude/agent-memory/<name>/  (shareable via VCS)
memory: local   # .claude/agent-memory-local/<name>/  (not committed)
```

When enabled: system prompt includes memory instructions + first 200 lines or 25KB of `MEMORY.md`; Read, Write, and Edit tools are automatically enabled.

### Scoped MCP Servers

```yaml
mcpServers:
  - playwright:           # inline definition — scoped to this subagent only
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github                # reference — reuses already-configured server
```

Inline servers connect when the subagent starts and disconnect when it finishes.

### Hooks in Subagent Frontmatter

Common hook events for subagents:

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

Project-level hooks in `settings.json` for subagent lifecycle:

| Event | When it fires |
| :--- | :--- |
| `SubagentStart` | When a subagent begins execution |
| `SubagentStop` | When a subagent completes |

### What Loads at Startup (Non-Fork Subagents)

| Item | Included? |
| :--- | :--- |
| Agent's own system prompt | Yes (all subagents) |
| CLAUDE.md files (all levels) | Yes — except Explore and Plan |
| Git status snapshot | Yes — except Explore and Plan |
| Preloaded skills (`skills` field) | Yes, if listed |
| Parent conversation history | No (use fork for this) |

### Foreground vs. Background Subagents

- **Foreground**: blocks main conversation; permission prompts surface interactively
- **Background**: runs concurrently; auto-denies tool calls that would prompt; press Ctrl+B to background a running task

Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks entirely.

### Invoke Subagents Explicitly

| Method | Behavior |
| :--- | :--- |
| Natural language | Name the subagent; Claude decides whether to delegate |
| `@"code-reviewer (agent)"` | Guarantees that subagent runs for one task |
| `claude --agent code-reviewer` | Whole session uses that subagent's prompt, tools, and model |
| `"agent": "code-reviewer"` in `.claude/settings.json` | Default agent for every session in a project |

Plugin subagents appear in the typeahead under scoped names like `my-plugin:code-reviewer`. For plugin agents in subfolders: `my-plugin:review:security`.

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

### Fork Mode (Experimental)

Requires Claude Code v2.1.117+. Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`.

A fork inherits the **full conversation history** instead of starting fresh — useful when a named subagent would need too much background context.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context with delegation prompt |
| System prompt & tools | Same as main session | From the subagent definition file |
| Model | Same as main session | From subagent `model` field |
| Prompt cache | Shared with main session | Separate cache |

When fork mode is enabled:
- Claude uses forks wherever it would otherwise use general-purpose subagents
- Every subagent spawn runs in the background
- `/fork` spawns a fork instead of acting as a `/branch` alias

Start a fork manually: `/fork draft unit tests for the parser changes so far`

Fork panel keyboard controls:

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork's transcript and send follow-up messages |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

A fork cannot spawn further forks.

### CLI Flag: --agents

Pass subagent definitions as JSON when launching Claude Code (session-only, not saved to disk):

```bash
claude --agents '{"code-reviewer": {"description": "...", "prompt": "...", "tools": ["Read", "Grep"], "model": "sonnet"}}'
```

Accepts the same fields as file-based frontmatter, using `prompt` for the system prompt body.

### Common Patterns

| Pattern | How |
| :--- | :--- |
| Isolate verbose output | "Use a subagent to run the test suite and report only failing tests" |
| Parallel research | "Research the auth, database, and API modules in parallel using separate subagents" |
| Chain subagents | "Use code-reviewer to find issues, then use optimizer to fix them" |
| Resume a subagent | "Continue that code review and now analyze the authorization logic" |

### When to Use Subagents vs. Main Conversation

Use **subagents** when:
- Task produces verbose output you don't need in main context
- You want to enforce tool restrictions or permissions
- Work is self-contained and can return a summary

Use **main conversation** when:
- Task needs frequent back-and-forth or iterative refinement
- Multiple phases share significant context
- Latency matters (subagents start fresh and re-gather context)

Use **Skills** instead when you want reusable prompts or workflows that run in the main conversation context.

### Auto-Compaction

Subagents support automatic compaction at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`). Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl` and are cleaned up per `cleanupPeriodDays` (default: 30 days).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, configuration options, frontmatter fields, tool control, permission modes, hooks, persistent memory, fork mode, invocation patterns, and example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
