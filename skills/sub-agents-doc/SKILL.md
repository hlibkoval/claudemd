---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating and configuring specialized AI subagents that handle specific tasks in their own context window. Covers built-in subagents (Explore, Plan, general-purpose), quickstart with /agents command, subagent scopes (CLI --agents, project .claude/agents/, user ~/.claude/agents/, plugin), frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection (sonnet/opus/haiku/inherit/full ID), tool restrictions (allowlist with tools, denylist with disallowedTools), restricting which subagents can be spawned (Agent(type) syntax), scoping MCP servers to subagents (inline definitions, string references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills into subagents, persistent memory (user/project/local scopes), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks for subagent events (SubagentStart, SubagentStop), automatic delegation, explicit invocation (natural language, @-mention, --agent session-wide), foreground vs background execution (Ctrl+B), common patterns (isolating high-volume operations, parallel research, chaining subagents), choosing between subagents and main conversation, resuming subagents (SendMessage with agent ID), auto-compaction, and example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation). Load when discussing Claude Code subagents, creating subagents, configuring subagents, subagent frontmatter, /agents command, Agent tool, delegating tasks, subagent tools, subagent permissions, subagent hooks, subagent memory, subagent MCP servers, background tasks, --agent flag, @-mention agents, subagent scopes, built-in agents (Explore, Plan, general-purpose), or subagent examples.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that handle specific tasks in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates to subagents automatically based on description matching, or you can invoke them explicitly.

Subagents work within a single session. For multiple agents working in parallel and communicating with each other, see agent teams instead.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only | File discovery, code search, codebase exploration. Thoroughness levels: quick, medium, very thorough |
| **Plan** | Inherits | Read-only | Codebase research during plan mode |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | -- | Running terminal commands in separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via /statusline |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

### Subagent Scopes (Priority Order)

| Location | Scope | Priority | How to create |
|:---------|:------|:---------|:--------------|
| `--agents` CLI flag | Current session only | 1 (highest) | Pass JSON when launching Claude Code |
| `.claude/agents/` | Current project | 2 | Interactive (`/agents`) or manual |
| `~/.claude/agents/` | All your projects | 3 | Interactive (`/agents`) or manual |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) | Installed with plugins |

When multiple subagents share the same name, the higher-priority location wins.

### Frontmatter Reference

Subagent files use YAML frontmatter + markdown body (system prompt). Only `name` and `description` are required.

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier, lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tools the subagent can use (allowlist). Inherits all if omitted |
| `disallowedTools` | No | Tools to deny, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID (e.g. `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into context at startup (full content, not just available for invocation) |
| `mcpServers` | No | MCP servers: inline definitions or string references to already-configured servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |

Plugin subagents ignore `hooks`, `mcpServers`, and `permissionMode` for security.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission checks (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden.

### Restricting Subagent Spawning

When running as main thread with `claude --agent`, use `Agent(type)` syntax in the `tools` field to restrict which subagents can be spawned:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

- `Agent(worker, researcher)` -- allowlist: only these subagents can be spawned
- `Agent` (no parentheses) -- allow spawning any subagent
- Omit `Agent` entirely -- agent cannot spawn any subagents

This only applies to agents running as main thread. Subagents cannot spawn other subagents.

To block specific subagents while allowing others, use `permissions.deny`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but private |

When enabled, the subagent's prompt includes the first 200 lines of `MEMORY.md` from its memory directory, and Read/Write/Edit tools are automatically available.

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| Natural language (name subagent in prompt) | Claude decides whether to delegate |
| `@"name (agent)"` (@-mention) | Guarantees the subagent runs for one task |
| `claude --agent <name>` | Whole session uses subagent's prompt, tools, and model |
| `agent` setting in `.claude/settings.json` | Default agent for every session in a project |

Plugin subagents: `@agent-<plugin>:<agent>` or `claude --agent <plugin>:<agent>`.

### Foreground vs Background

| Mode | Behavior |
|:-----|:---------|
| **Foreground** | Blocks main conversation. Permission prompts and questions pass through to user |
| **Background** | Runs concurrently. Permissions pre-approved at launch; unapproved requests auto-denied |

Press **Ctrl+B** to background a running task. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Subagent Hooks

**In frontmatter** (run while subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to SubagentStop at runtime) |

**In settings.json** (run in main session):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Resuming Subagents

Each subagent invocation creates a new instance. To continue an existing subagent's work, ask Claude to resume it. Claude uses `SendMessage` with the agent ID. Subagent transcripts persist independently (stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`). Main conversation compaction does not affect subagent transcripts.

### Auto-Compaction

Subagents support automatic compaction at approximately 95% capacity (configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

### CLI-Defined Subagents

Pass subagents as JSON via `--agents` (session-only, not saved to disk):

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

Accepts the same fields as file-based frontmatter. Use `prompt` for the system prompt (equivalent to markdown body).

### Common Patterns

- **Isolate high-volume operations**: delegate tests, log processing, doc fetching to keep verbose output out of main context
- **Parallel research**: spawn multiple subagents for independent investigations
- **Chain subagents**: use subagents in sequence, each receiving relevant context from the previous

### When to Use Subagents vs Alternatives

| Use case | Recommended approach |
|:---------|:--------------------|
| Self-contained task returning a summary | Subagent |
| Verbose output you do not need in main context | Subagent |
| Enforcing specific tool restrictions | Subagent |
| Frequent back-and-forth or iterative refinement | Main conversation |
| Quick targeted change | Main conversation |
| Reusable prompts in main conversation context | Skills |
| Quick question using full conversation context | /btw |
| Sustained parallelism or independent context windows | Agent teams |

Subagents cannot spawn other subagents. For nested delegation, use skills or chain subagents from the main conversation.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes (CLI --agents, project .claude/agents/, user ~/.claude/agents/, plugin agents/), writing subagent files (frontmatter + markdown body), supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, isolation), model selection, tool restrictions (allowlist/denylist), restricting subagent spawning (Agent(type) syntax), scoping MCP servers (inline/reference), permission modes, preloading skills, persistent memory (user/project/local), conditional rules with PreToolUse hooks, disabling subagents via permissions.deny, hooks in frontmatter and settings.json (SubagentStart, SubagentStop), automatic delegation, explicit invocation (natural language, @-mention, --agent), foreground vs background execution, common patterns (isolating operations, parallel research, chaining), choosing subagents vs main conversation, resuming subagents, auto-compaction, example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
