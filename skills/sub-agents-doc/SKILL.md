---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents — creating, configuring, scoping, and working with specialized AI assistants that run in isolated context windows.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Fast codebase search and analysis; skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Research during plan mode; skips CLAUDE.md and git status |
| **General-purpose** | Inherits | All | Complex multi-step tasks requiring exploration and modification |
| **statusline-setup** | Sonnet | — | Invoked by `/statusline`; configures the status line |
| **claude-code-guide** | Haiku | — | Answers questions about Claude Code features |

Disable a specific subagent: add `Agent(subagent-name)` to `permissions.deny` in settings, or use `--disallowedTools "Agent(Explore)"`. Disable all built-ins in SDK/non-interactive mode: set `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1`.

### Subagent File Format

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices. Use proactively after changes.
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide specific, actionable feedback.
```

### Supported Frontmatter Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `name` | Yes | Unique identifier, lowercase + hyphens. Hooks receive this as `agent_type`. Filename need not match |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted. Use `Agent(worker, researcher)` syntax to restrict which subagents can be spawned |
| `disallowedTools` | No | Denylist; applied first when both `tools` and `disallowedTools` are set |
| `model` | No | `sonnet`, `opus`, `haiku`, `fable`, full model ID (e.g. `claude-opus-4-8`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan`. Ignored for plugin subagents |
| `maxTurns` | No | Max agentic turns before the subagent stops |
| `skills` | No | Skills to preload into context at startup (full content injected) |
| `mcpServers` | No | MCP servers scoped to this subagent (inline definitions or string references). Ignored for plugin subagents |
| `hooks` | No | Lifecycle hooks for this subagent. Ignored for plugin subagents |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `xhigh`, `max`; overrides session effort level |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted first user turn when agent runs as main session via `--agent` or `agent` setting |

### Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

Same-name conflict: higher-priority location wins. Within `.claude/agents/` nested directories, closest to working directory wins (v2.1.178+). Directories are scanned recursively; identity comes from the `name` field only.

### Model Resolution Order

When Claude invokes a subagent, the model is resolved in this order:
1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands in working dir |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Plan mode — read-only exploration |

If the parent uses `bypassPermissions` or `acceptEdits`, those take precedence and cannot be overridden. Parent `auto` mode cascades to subagent; subagent `permissionMode` is ignored in that case.

### Tool Control

Restrict with an allowlist:
```yaml
tools: Read, Grep, Glob, Bash
```

Restrict with a denylist (inherits everything except listed tools):
```yaml
disallowedTools: Write, Edit
```

MCP server-level patterns: `mcp__<server>` or `mcp__<server>__*`. In `disallowedTools`, `mcp__*` removes all MCP tools.

Restrict which sub-types can be spawned (main thread only, via `--agent`):
```yaml
tools: Agent(worker, researcher), Read, Bash
```

Unavailable tools (not usable even when listed): `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless subagent `permissionMode` is `plan`), `ScheduleWakeup`, `WaitForMcpServers`.

### Persistent Memory Scopes

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not committed |

When enabled: first 200 lines or 25KB of `MEMORY.md` loads at startup; Read, Write, Edit are auto-enabled for the subagent.

### Hooks in Subagent Frontmatter

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (becomes `SubagentStop` at runtime) |

### Project-Level Subagent Lifecycle Hooks (settings.json)

| Event | Matcher input | When it fires |
| :--- | :--- | :--- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### What Loads at Startup (Non-Fork Subagents)

| Item | Loads | Notes |
| :--- | :--- | :--- |
| System prompt | Always | Subagent's own prompt + environment details (not full Claude Code system prompt) |
| Task message | Always | Delegation prompt Claude writes |
| CLAUDE.md and memory | Always | Full hierarchy including managed policies | 
| Git status | Unless skipped | Absent when not a git repo or `includeGitInstructions: false` |
| Preloaded skills | When listed | Full content of skills in `skills` field |
| Explore / Plan | Skip CLAUDE.md and git status | Only built-ins with this exception |

### Invoking Subagents

| Method | Guarantees invocation | Persists |
| :--- | :--- | :--- |
| Natural language ("use the X subagent") | No — Claude decides | No |
| `@"code-reviewer (agent)"` @-mention | Yes, for that task | No |
| `claude --agent code-reviewer` | Yes, entire session | For resumed sessions |
| `agent: "code-reviewer"` in `.claude/settings.json` | Yes, every session | Until changed |

Plugin subagents: `@agent-my-plugin:code-reviewer`. Scoped name for `--agent`: `claude --agent my-plugin:security-reviewer`.

### Foreground vs Background

- **Foreground**: blocks main conversation; permission prompts surface to user
- **Background**: concurrent; auto-denies tool calls that would prompt; fails silently on missing permissions
- Press **Ctrl+B** to background a running task, or ask Claude to "run this in the background"
- Disable all background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`
- Background subagents at depth 5 cannot spawn further subagents

### Nested Subagents (v2.1.172+)

Subagents can spawn their own subagents. Foreground subagents can spawn at any depth (each level blocks its parent). Background subagents cap at depth 5. To prevent spawning, omit `Agent` from `tools` or add it to `disallowedTools`. A fork cannot spawn another fork.

### Subagent Transcripts

Stored at: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`

- Persist independently from main conversation
- Unaffected by main conversation compaction
- Cleaned up after `cleanupPeriodDays` (default: 30 days)
- Resume a stopped subagent: Claude uses `SendMessage` with the agent ID (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)

### Fork vs Named Subagent

|  | Fork | Named subagent |
| :--- | :--- | :--- |
| Context | Full conversation history | Fresh context |
| System prompt | Same as main session | From definition file |
| Model | Same as main session | From `model` field |
| Permissions | Prompts in terminal | Auto-denied (background) |
| Prompt cache | Shared with main session | Separate cache |

Start a fork: `/fork draft unit tests for the parser changes so far`

Control fork mode: `CLAUDE_CODE_FORK_SUBAGENT=1` (enable) or `=0` (disable). Enabled by default as of v2.1.161.

### Fork Panel Keys

| Key | Action |
| :--- | :--- |
| `↑` / `↓` | Move between rows |
| `Enter` | Open fork transcript / send follow-up |
| `x` | Dismiss finished fork or stop running one |
| `Esc` | Return focus to prompt input |

### Common Patterns

| Goal | Approach |
| :--- | :--- |
| Keep verbose output out of main context | Delegate test runs, log processing, doc fetches to a subagent |
| Parallel independent research | Ask Claude to use separate subagents concurrently |
| Multi-step workflow | Chain subagents in sequence; each returns summary to Claude |
| Fine-grained tool control | Use `PreToolUse` hooks to validate operations (e.g., block SQL writes) |
| Reusable prompts in main context | Use Skills instead of subagents |
| Quick side question with full context | Use `/btw` (no tools, answer discarded) |

### When to Use Subagents vs Main Conversation

Use **subagents** when: task produces verbose output; you want tool restrictions; work is self-contained and can summarize.

Use **main conversation** when: task needs back-and-forth; phases share significant context; change is quick/targeted; latency matters (subagents start fresh).

### MCP Servers in Subagents (mcpServers field)

```yaml
mcpServers:
  # Inline definition scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference to an already-configured server
  - github
```

Inline servers connect when subagent starts, disconnect when it finishes. Inline server defined here keeps the tools out of the parent conversation's context. MCP restrictions (`--strict-mcp-config`, `--bare`, enterprise managed MCP) apply to inline servers as of v2.1.153.

### CLI-Defined Subagents (--agents flag)

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

Session-only; not saved to disk. The `prompt` field is equivalent to the markdown body in file-based subagents.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Built-in subagents, quickstart, frontmatter reference, tool/permission/MCP/hook configuration, invocation patterns, forking, context management, examples

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
