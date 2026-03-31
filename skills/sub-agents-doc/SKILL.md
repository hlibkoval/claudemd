---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents (custom AI subagents) -- creating, configuring, and managing specialized subagents that run in isolated context windows. Covers built-in subagents (Explore with Haiku read-only, Plan for plan mode research, general-purpose with all tools, Bash/statusline-setup/Claude Code Guide helpers), quickstart with /agents command (create, generate with Claude, select tools/model/color/memory, save), subagent scopes and priority (--agents CLI JSON highest, .claude/agents/ project, ~/.claude/agents/ user, plugin agents/ lowest), writing subagent files (YAML frontmatter + markdown body as system prompt), all frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model resolution order (CLAUDE_CODE_SUBAGENT_MODEL env var > per-invocation > frontmatter > parent model), tool control (tools allowlist, disallowedTools denylist, Agent(type) spawn restriction, permissions.deny to disable agents), MCP server scoping (inline definitions and string references in mcpServers field), permission modes (default/acceptEdits/dontAsk/bypassPermissions/plan, parent bypassPermissions takes precedence, auto mode inheritance), preloading skills into subagents, persistent memory (user/project/local scopes, memory directory, MEMORY.md, cross-session learning), hooks in subagent frontmatter (PreToolUse/PostToolUse/Stop events, Stop converted to SubagentStop), project-level hooks (SubagentStart/SubagentStop events in settings.json with matchers), working with subagents (automatic delegation via description, natural language invocation, @-mention for guaranteed delegation, --agent flag for session-wide, agent setting in settings.json), foreground vs background subagents (Ctrl+B to background, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), common patterns (isolate high-volume operations, parallel research, chain subagents), choosing subagents vs main conversation, resume subagents (SendMessage with agent ID, transcript persistence, subagent transcript files), auto-compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation), plugin subagent restrictions (no hooks/mcpServers/permissionMode from plugins). Load when discussing Claude Code subagents, custom agents, agent creation, /agents command, subagent configuration, subagent tools, subagent model, subagent permissions, subagent hooks, subagent memory, subagent scopes, built-in agents Explore/Plan, --agent flag, @-mention agents, background subagents, foreground subagents, Agent tool, agent teams vs subagents, subagent context, resume subagent, subagent MCP servers, subagent skills preloading, agent isolation worktree, subagent delegation, disallowedTools, Agent(type) spawn restriction, SubagentStart/SubagentStop hooks, persistent agent memory, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents -- specialized AI assistants that handle specific tasks in isolated context windows with custom system prompts, tool access, and independent permissions.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for plan mode |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal commands | Running commands in a separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore uses thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive analysis).

### Subagent Scopes and Priority

| Location | Scope | Priority | How to create |
|:---------|:------|:---------|:--------------|
| `--agents` CLI flag | Current session | 1 (highest) | Pass JSON when launching Claude Code |
| `.claude/agents/` | Current project | 2 | Interactive (`/agents`) or manual |
| `~/.claude/agents/` | All your projects | 3 | Interactive or manual |
| Plugin's `agents/` directory | Where plugin is enabled | 4 (lowest) | Installed with plugins |

When multiple subagents share the same name, the higher-priority location wins.

### Subagent File Format

YAML frontmatter for configuration + Markdown body as system prompt:

```
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze the code and provide
specific, actionable feedback on quality, security, and best practices.
```

Subagents receive only this system prompt (plus basic environment details like working directory), not the full Claude Code system prompt.

### All Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier, lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tools the subagent can use. Inherits all if omitted |
| `disallowedTools` | No | Tools to deny, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, a full model ID (e.g. `claude-opus-4-6`), or `inherit`. Default: `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into context at startup (full content, not just availability) |
| `mcpServers` | No | MCP servers: string references or inline definitions |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task. Default: `false` |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only). Overrides session |
| `isolation` | No | `worktree` to run in a temporary git worktree (auto-cleaned if no changes) |
| `initialPrompt` | No | Auto-submitted first user turn when running as main session agent via `--agent` |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter (set by Claude when delegating)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool Control

**Allowlist** -- `tools` field restricts to only listed tools:
```yaml
tools: Read, Grep, Glob, Bash
```

**Denylist** -- `disallowedTools` field removes specific tools from inherited set:
```yaml
disallowedTools: Write, Edit
```

If both are set, `disallowedTools` is applied first, then `tools` resolves against the remaining pool.

**Restrict spawnable subagents** -- when running as main thread with `--agent`, use `Agent(type)` syntax:
```yaml
tools: Agent(worker, researcher), Read, Bash
```
Only `worker` and `researcher` can be spawned. Omitting `Agent` entirely prevents spawning any subagents. This restriction only applies to agents running as main thread via `--agent`; subagents cannot spawn other subagents.

**Disable specific subagents** via `permissions.deny` in settings:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```
Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### MCP Server Scoping

```yaml
mcpServers:
  # Inline definition: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses already-configured server
  - github
```

Inline definitions use the same schema as `.mcp.json` entries. Inline servers connect when the subagent starts and disconnect when it finishes. Defining MCP servers inline keeps their tool descriptions out of the main conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If the parent uses `bypassPermissions`, it takes precedence and cannot be overridden. If the parent uses auto mode, the subagent inherits auto mode and its `permissionMode` frontmatter is ignored.

### Preloading Skills

```yaml
skills:
  - api-conventions
  - error-handling-patterns
```

Full skill content is injected into the subagent's context at startup. Subagents do not inherit skills from the parent conversation -- list them explicitly.

### Persistent Memory

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings should apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via version control |
| `local` | `.claude/agent-memory-local/<name>/` | Knowledge is project-specific but should not be checked in |

When memory is enabled: system prompt includes read/write instructions, first 200 lines or 25KB of `MEMORY.md` is loaded, and Read/Write/Edit tools are automatically enabled. `project` is the recommended default scope.

### Hooks

**In subagent frontmatter** -- run only while that subagent is active:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In settings.json** -- project-level hooks for subagent lifecycle:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| **Automatic** | Claude delegates based on task + subagent description |
| **Natural language** | Name the subagent in your prompt; Claude decides |
| **@-mention** | `@"code-reviewer (agent)"` -- guarantees that subagent runs |
| **`--agent` flag** | `claude --agent code-reviewer` -- entire session uses the subagent's config |
| **`agent` setting** | `{"agent": "code-reviewer"}` in `.claude/settings.json` -- default for all sessions |

For plugin subagents: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs Background

| | Foreground | Background |
|:--|:-----------|:-----------|
| **Blocks main conversation** | Yes | No |
| **Permission prompts** | Passed through to user | Pre-approved before launch; auto-denied otherwise |
| **Clarifying questions** | Passed through | Tool call fails, subagent continues |

Background a running task with **Ctrl+B**. Disable background tasks entirely with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resume Subagents

Each subagent invocation creates a new instance with fresh context. To continue existing work, ask Claude to resume it. Resumed subagents retain full conversation history. Claude uses `SendMessage` with the agent ID to resume. Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

Transcripts persist independently of main conversation compaction and are cleaned up based on `cleanupPeriodDays` setting (default: 30 days).

### Auto-compaction

Subagents support automatic compaction at approximately 95% capacity. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g. `50` for earlier compaction).

### When to Use What

| Situation | Use |
|:----------|:----|
| Frequent back-and-forth, iterative refinement | Main conversation |
| Quick targeted change, latency matters | Main conversation |
| Verbose output you don't need in main context | Subagent |
| Enforce specific tool restrictions or permissions | Subagent |
| Self-contained work that returns a summary | Subagent |
| Reusable prompts/workflows in main context | Skills |
| Quick question using current context, no tools | `/btw` |
| Sustained parallelism or exceeds context window | Agent teams |

Subagents cannot spawn other subagents. For nested delegation, use skills or chain subagents from the main conversation.

### CLI-defined Subagents (JSON)

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

The `--agents` flag accepts the same frontmatter fields. Use `prompt` for the system prompt (equivalent to the markdown body in file-based subagents).

### Plugin Subagent Restrictions

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` fields (ignored when loading from a plugin). Copy the agent file into `.claude/agents/` or `~/.claude/agents/` if you need these features.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- Built-in subagents, quickstart with /agents, all configuration options, tool control, hooks, memory, invocation patterns, foreground/background, common patterns, and example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
