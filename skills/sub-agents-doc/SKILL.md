---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — specialized AI assistants that run in their own context window with custom system prompts, tool access, and permissions. Covers built-in subagents (Explore, Plan, general-purpose), creating custom subagents via /agents or file-based YAML frontmatter, scopes and priority, all supported frontmatter fields (tools, disallowedTools, model, permissionMode, mcpServers, hooks, skills, memory, background, effort, isolation, color, initialPrompt, maxTurns), lifecycle hooks, automatic delegation, @-mention and --agent invocation, foreground vs background execution, persistent memory, resuming subagents, auto-compaction, and worked examples.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Claude delegates side tasks to a subagent so verbose output (search results, logs, file contents) stays out of the main conversation. Each subagent returns only a summary to the caller.

**Subagents vs agent teams**: subagents are one-shot workers that return a summary to the main session. Agent teams coordinate multiple sessions with direct inter-agent messaging. Subagents cannot spawn other subagents.

### Built-in subagents

| Subagent | Model | Tools | Purpose |
| :-- | :-- | :-- | :-- |
| **Explore** | Haiku | Read-only (Write/Edit denied) | Fast file discovery, code search, codebase exploration. Thoroughness: quick / medium / very thorough |
| **Plan** | Inherit | Read-only (Write/Edit denied) | Research during plan mode to gather context without infinite nesting |
| **general-purpose** | Inherit | All tools | Complex multi-step tasks requiring both exploration and action |
| **statusline-setup** | Sonnet | - | Auto-invoked for `/statusline` |
| **Claude Code Guide** | Haiku | - | Auto-invoked for questions about Claude Code features |

### Subagent scopes (priority order)

| Location | Scope | Priority |
| :-- | :-- | :-- |
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag (JSON) | Current session | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When duplicate names exist, the higher-priority location wins. Project subagents are discovered by walking up from CWD. `--add-dir` paths are not scanned. Plugin subagents **cannot** use `hooks`, `mcpServers`, or `permissionMode` (fields are ignored for security).

### File format

Subagents are Markdown files with YAML frontmatter; the body is the system prompt.

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

Subagents receive only this system prompt plus minimal environment details — not the full Claude Code system prompt. A subagent starts in the main conversation's CWD; `cd` does not persist between tool calls. Subagents are loaded at session start — restart or use `/agents` after manually adding a file.

### Supported frontmatter fields

| Field | Required | Description |
| :-- | :-- | :-- |
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools. Inherits all if omitted |
| `disallowedTools` | No | Denylist (applied before `tools` allowlist resolution) |
| `model` | No | `sonnet`, `opus`, `haiku`, full ID (e.g. `claude-opus-4-6`), or `inherit`. Default `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Max agentic turns before stopping |
| `skills` | No | Skills to inject at startup (full content, not just made discoverable). Not inherited from parent |
| `mcpServers` | No | Inline MCP server defs or references to already-configured servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | `user`, `project`, or `local` — enables persistent cross-session memory |
| `background` | No | `true` to always run as background task. Default `false` |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only). Overrides session effort |
| `isolation` | No | `worktree` runs the subagent in a temporary git worktree |
| `color` | No | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when this agent runs as the main session agent |

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` env var
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool restrictions

Use `tools` (allowlist) or `disallowedTools` (denylist). If both are set, `disallowedTools` runs first, then `tools` resolves against the remaining pool. A tool listed in both is removed.

```yaml
# Allowlist
tools: Read, Grep, Glob, Bash
```

```yaml
# Denylist — inherits everything except Write and Edit
disallowedTools: Write, Edit
```

**Restricting which subagents can be spawned** (only applies to `claude --agent` main-thread agents): use `Agent(type1, type2)` in `tools` as an allowlist, bare `Agent` to allow any, or omit `Agent` entirely to block all spawning. Subagents cannot spawn other subagents, so this has no effect in subagent definitions. Block a specific subagent across the session with `permissions.deny: ["Agent(Explore)"]` in settings.

### Permission modes

| Mode | Behavior |
| :-- | :-- |
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept edits and common filesystem commands for working-dir paths |
| `auto` | Background classifier reviews commands and protected-dir writes |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Read-only plan mode |

If the parent uses `bypassPermissions`, it takes precedence. If the parent uses `auto`, the subagent inherits `auto` and any `permissionMode` in its frontmatter is ignored.

### Persistent memory scopes

| Scope | Location | Use when |
| :-- | :-- | :-- |
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, share via version control (**recommended default**) |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When memory is enabled: the system prompt includes read/write instructions plus the first 200 lines or 25KB of `MEMORY.md` (whichever comes first), with curation instructions beyond that. Read, Write, Edit tools are auto-enabled.

### Lifecycle hooks

Hooks can be defined inside the subagent's frontmatter (scoped to that subagent, cleaned up when it finishes) or in `settings.json` (main-session events).

**In subagent frontmatter** — common events:

| Event | Matcher | Fires |
| :-- | :-- | :-- |
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** — main-session events:

| Event | Matcher | Fires |
| :-- | :-- | :-- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

`PreToolUse` hooks receiving JSON via stdin can exit 2 to block with a stderr message — useful for fine-grained conditional validation (e.g., allowing only SELECT SQL queries).

### MCP servers on subagents

`mcpServers` entries are either inline server definitions (scoped to the subagent, connected on spawn, disconnected on exit) or string references to already-configured servers (share parent session's connection). Inline-only lets you keep an MCP server's tool descriptions out of the main conversation entirely.

### Invocation patterns

| Pattern | Effect |
| :-- | :-- |
| **Natural language** | Name the subagent in your prompt; Claude decides whether to delegate |
| **@-mention** | `@"code-reviewer (agent)"` — guarantees that subagent runs for one task |
| **`--agent <name>`** | Whole session adopts the subagent's system prompt, tools, model |
| **`agent` setting** | `.claude/settings.json` default for every session in a project |

Plugin subagents appear in the typeahead as `<plugin-name>:<agent-name>`. The `--agent` flag fully replaces the Claude Code system prompt (CLAUDE.md still loads via message flow) and persists across session resume. CLI flag overrides the setting.

### Foreground vs background

- **Foreground** (blocking): permission prompts and `AskUserQuestion` pass through to you.
- **Background** (concurrent): tool permissions must be pre-approved at launch. Unapproved operations auto-deny. Clarifying questions fail silently but the subagent continues.

Claude decides automatically; you can ask "run this in the background" or press **Ctrl+B** to background a running task. Disable all background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming subagents & transcripts

Each invocation creates a fresh instance. To continue an existing subagent, ask Claude to resume it — it uses the `SendMessage` tool (requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) with the agent ID. Resumed subagents retain full history. A stopped subagent receiving `SendMessage` auto-resumes in background.

- Transcripts: `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Unaffected by main-conversation compaction (stored separately)
- Persist within the session; resume via session resume
- Auto-cleanup per `cleanupPeriodDays` setting (default 30)
- Auto-compaction triggers at ~95% capacity; override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`

### `/agents` and CLI listing

- `/agents` opens a tabbed interface: **Running** (live subagents, open/stop), **Library** (view/create/edit/delete built-in, user, project, plugin)
- `claude agents` lists all configured subagents from the command line, grouped by source

### `--agents` CLI flag (JSON)

Define session-only subagents without files:

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on quality, security, best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

Accepts all frontmatter fields. Use `prompt` for the system prompt.

### Subagents vs main conversation vs skills

Use the **main conversation** when the task needs iterative refinement, shares context across phases, is a quick targeted change, or when latency matters.

Use **subagents** when the task produces verbose output you don't need, you want to enforce tool restrictions, or the work is self-contained and can return a summary.

Consider **Skills** instead when you want reusable prompts that run in the main conversation context. For a quick question about something already in the conversation, use `/btw`.

### Common patterns

- **Isolate high-volume operations** — tests, docs fetches, log processing stay in the subagent's context
- **Parallel research** — spawn multiple subagents for independent investigations (beware combined return cost)
- **Chain subagents** — sequence multi-step workflows, passing relevant context between them

### Best practices

- Design focused subagents that excel at one specific task
- Write detailed descriptions — Claude uses them to decide when to delegate; include "use proactively" to encourage delegation
- Limit tool access for security and focus
- Check project subagents into version control to share with the team

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full official guide covering built-in subagents, quickstart, scope priority, all frontmatter fields, tool restrictions, permission modes, MCP scoping, skill preloading, persistent memory, lifecycle hooks, automatic delegation, @-mention and --agent invocation, foreground/background execution, common patterns, subagent resumption, auto-compaction, and worked examples (code-reviewer, debugger, data-scientist, db-reader)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
