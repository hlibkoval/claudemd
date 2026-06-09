---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents: creating, configuring, invoking, and managing specialized AI subagents within a session.

## Quick Reference

### What Are Subagents?

Subagents are specialized AI assistants that each run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them to:

- **Preserve context** — keep verbose output (test runs, logs, research) out of the main conversation
- **Enforce constraints** — limit tool access for safety or focus
- **Reuse configurations** — user-level subagents work across all projects
- **Control costs** — route tasks to faster, cheaper models like Haiku

Subagents cannot spawn other subagents. For nested delegation, use Skills or chain subagents from the main conversation.

### Built-in Subagents

| Name | Model | Tools | When Claude uses it |
| :--- | :--- | :--- | :--- |
| **Explore** | Haiku | Read-only | Searching and analyzing codebases; skips CLAUDE.md and git status |
| **Plan** | Inherits | Read-only | Research during plan mode; skips CLAUDE.md and git status |
| **General-purpose** | Inherits | All | Complex multi-step tasks needing both exploration and modification |
| **statusline-setup** | Sonnet | — | When you run `/statusline` |
| **claude-code-guide** | Haiku | — | Questions about Claude Code features |

### Subagent Scope and Priority

| Location | Scope | Priority |
| :--- | :--- | :--- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Fields

Only `name` and `description` are required. All others are optional.

| Field | Description |
| :--- | :--- |
| `name` | Unique identifier (lowercase + hyphens). Hooks receive this as `agent_type` |
| `description` | When Claude should delegate to this subagent |
| `tools` | Allowlist of tools. Inherits all tools if omitted. Use `Agent(name)` syntax to restrict which subagents can be spawned |
| `disallowedTools` | Denylist — removed from inherited or specified list. Applied before `tools` |
| `model` | `sonnet`, `opus`, `haiku`, a full model ID (e.g. `claude-opus-4-8`), or `inherit`. Defaults to `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | Maximum agentic turns before the subagent stops |
| `skills` | Skills to preload into subagent context at startup (full content injected) |
| `mcpServers` | MCP servers for this subagent. Inline entries are scoped to the subagent; string references reuse the parent session's connection |
| `hooks` | Lifecycle hooks scoped to this subagent (ignored for plugin subagents) |
| `memory` | Persistent memory scope: `user`, `project`, or `local` |
| `background` | `true` to always run as a background task. Default: `false` |
| `effort` | Effort level: `low`, `medium`, `high`, `xhigh`, `max`. Overrides session effort |
| `isolation` | `worktree` to run in a temporary git worktree (isolated copy of repo) |
| `color` | UI color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | Auto-submitted first user turn when this agent runs as the main session via `--agent` or the `agent` setting |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tools Not Available to Subagents

Even when listed in `tools`, these are unavailable:
- `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ScheduleWakeup`, `WaitForMcpServers`
- `ExitPlanMode` (unless subagent's `permissionMode` is `plan`)

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands |
| `auto` | Background classifier reviews commands and writes to protected directories |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts — use with caution |
| `plan` | Plan mode (read-only exploration) |

If parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden by the subagent.

### Persistent Memory

| Scope | Location | Use when |
| :--- | :--- | :--- |
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but should not be checked in |

When enabled: subagent system prompt includes memory directory instructions and first 200 lines / 25KB of `MEMORY.md`. Read, Write, and Edit tools are automatically enabled.

### What Loads at Subagent Startup

Non-fork subagents start with a fresh context containing:

- **System prompt**: agent's own prompt + environment details (not the full Claude Code system prompt)
- **Task message**: the delegation prompt Claude writes
- **CLAUDE.md and memory**: full memory hierarchy (Explore and Plan skip this)
- **Git status**: snapshot from parent session start (Explore and Plan skip this)
- **Preloaded skills**: full content of skills listed in the `skills` field

### Foreground vs. Background

| | Foreground | Background |
| :--- | :--- | :--- |
| **Blocking** | Yes — main conversation waits | No — runs concurrently |
| **Permissions** | Prompts passed through to you | Auto-denied if they would prompt |
| **Ctrl+B** | Moves running task to background | — |

To disable all background tasks: set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Invoking Subagents

| Method | Effect |
| :--- | :--- |
| Natural language: name the subagent | Claude decides whether to delegate |
| `@"subagent-name (agent)"` @-mention | Guarantees that specific subagent runs for one task |
| `claude --agent <name>` | Entire session uses that subagent's system prompt, tools, and model |
| `"agent": "name"` in `.claude/settings.json` | Default for every session in the project |

For plugin-provided subagents, use scoped names: `my-plugin:agent-name` or `my-plugin:subfolder:agent-name`.

### Disabling Subagents

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Hooks for Subagents

**In frontmatter** — run only while that subagent is active:

| Event | When |
| :--- | :--- |
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** — respond to subagent lifecycle in the main session:

| Event | When |
| :--- | :--- |
| `SubagentStart` | When a subagent begins execution |
| `SubagentStop` | When a subagent completes |

### Fork Mode

A fork inherits the entire conversation instead of starting fresh. Use when a named subagent would need too much background to be useful, or to try multiple approaches in parallel.

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` (or v2.1.161+ default). Start manually with `/fork <directive>`.

| | Fork | Named subagent |
| :--- | :--- | :--- |
| **Context** | Full conversation history | Fresh context with delegation prompt |
| **System prompt & tools** | Same as main session | From subagent definition file |
| **Model** | Same as main session | From subagent `model` field |
| **Prompt cache** | Shared with main session | Separate cache |

A fork cannot spawn further forks. When `CLAUDE_CODE_FORK_SUBAGENT=1`, Claude uses a fork wherever it would otherwise use the general-purpose subagent, and all subagent spawns run in the background.

### Common Patterns

- **Isolate high-volume operations**: Run tests or fetch docs in a subagent; only summary returns to main context
- **Parallel research**: Spawn multiple subagents to investigate independent areas simultaneously
- **Chain subagents**: Use subagents in sequence — each completes its task, then Claude passes relevant context to the next
- **Conditional tool control**: Use `PreToolUse` hooks to allow a tool (e.g. Bash) while blocking specific operations within it

### CLI Flag: `--agents`

Pass JSON when launching Claude Code. Same frontmatter fields apply; use `prompt` for the system prompt body.

```bash
claude --agents '{"code-reviewer": {"description": "...", "prompt": "...", "tools": ["Read", "Grep"]}}'
```

Exists only for that session; not saved to disk.

### Subagent Transcripts

Stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Persist independently of the main conversation. Auto-cleaned after `cleanupPeriodDays` (default: 30 days).

Resume a stopped subagent by asking Claude to continue its previous work. Claude uses the `SendMessage` tool (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — built-in subagents, quickstart, all configuration options, tool control, permission modes, persistent memory, hooks, fork mode, example subagents, and invocation patterns

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
