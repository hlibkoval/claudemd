---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating, configuring, and managing custom subagents. Covers built-in subagents (Explore, Plan, general-purpose), subagent file format (YAML frontmatter fields), scope and priority (managed, CLI, project, user, plugin), tool access control (tools, disallowedTools, Agent(type) restrictions), model selection (sonnet, opus, haiku, inherit, full IDs, resolution order), permission modes (default, acceptEdits, auto, dontAsk, bypassPermissions, plan), MCP server scoping (inline definitions, named references), persistent memory (user, project, local scopes), skills preloading, hooks in frontmatter (PreToolUse, PostToolUse, Stop), project-level hooks (SubagentStart, SubagentStop), isolation via git worktrees, foreground vs background execution, auto-delegation, explicit invocation (@-mention, --agent flag, agent setting), subagent resumption (SendMessage, agent IDs), context management (auto-compaction, transcript persistence), disabling subagents (permissions.deny, --disallowedTools), and example subagents (code-reviewer, debugger, data-scientist, db-reader with hook validation). Load when discussing subagents, custom agents, Agent tool, agent delegation, agent teams vs subagents, /agents command, agent configuration, agent frontmatter, agent memory, agent permissions, agent hooks, agent isolation, background agents, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents -- specialized AI assistants that handle specific types of tasks with their own context window, system prompt, tool access, and permissions.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|:------|:------|:------|:--------|
| Explore | Haiku | Read-only | File discovery, code search, codebase exploration |
| Plan | Inherited | Read-only | Codebase research for planning (plan mode) |
| General-purpose | Inherited | All tools | Complex research, multi-step operations, code modifications |
| statusline-setup | Sonnet | -- | Configures status line via `/statusline` |
| Claude Code Guide | Haiku | -- | Answers questions about Claude Code features |

### Subagent Scope and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:-----------|
| `name` | Yes | Unique identifier using lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tools the subagent can use (inherits all if omitted) |
| `disallowedTools` | No | Tools to deny, removed from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before the subagent stops |
| `skills` | No | Skills to inject into the subagent's context at startup |
| `mcpServers` | No | MCP servers available to this subagent (inline or named reference) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, or `max` (Opus 4.6 only). Default: inherited |
| `isolation` | No | Set to `worktree` for isolated git worktree execution |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when running as main agent via `--agent` |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter (passed by Claude at delegation time)
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits except in protected directories |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

If parent uses `bypassPermissions`, it takes precedence. If parent uses `auto`, the subagent inherits auto mode and `permissionMode` frontmatter is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Knowledge applies across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked into VCS |

When memory is enabled, the subagent's system prompt includes the first 200 lines or 25KB of `MEMORY.md` from the memory directory. Read, Write, and Edit tools are automatically enabled.

### MCP Server Scoping

Subagents can access MCP servers via inline definitions or named references:

```yaml
mcpServers:
  # Inline definition: scoped to this subagent only
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # Reference by name: reuses an already-configured server
  - github
```

Inline definitions keep MCP tools out of the main conversation's context.

### Hooks in Subagent Frontmatter

| Event | Matcher input | When it fires |
|:------|:-------------|:-------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

All hook events are supported. `Stop` hooks in frontmatter are automatically converted to `SubagentStop` events.

### Project-Level Subagent Hooks (in settings.json)

| Event | Matcher input | When it fires |
|:------|:-------------|:-------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Tool Access Control

- **`tools` field**: Allowlist of tools the subagent can use
- **`disallowedTools` field**: Denylist removed from inherited tools
- If both set, `disallowedTools` is applied first, then `tools` resolved against remaining pool
- **`Agent(type)` syntax**: Restrict which subagent types can be spawned (only applies to `--agent` main thread)
- Omitting `Agent` from `tools` prevents spawning any subagents

### Invocation Methods

| Method | Behavior |
|:-------|:---------|
| Natural language (name the agent) | Claude decides whether to delegate |
| `@"agent-name (agent)"` mention | Guarantees the subagent runs for one task |
| `claude --agent <name>` | Whole session uses the subagent's config |
| `agent` in `.claude/settings.json` | Default agent for all sessions in a project |

### Foreground vs Background

- **Foreground**: Blocks main conversation; permission prompts pass through to user
- **Background**: Runs concurrently; permissions pre-approved before launch; auto-denies unapproved tools
- Claude decides automatically, or user can say "run in the background" or press **Ctrl+B**
- Disable background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Disabling Subagents

Add to `permissions.deny` in settings or use CLI flag:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### Subagent Context Management

- Subagents cannot spawn other subagents
- Each invocation creates a new instance with fresh context
- Resume via `SendMessage` tool (requires agent teams: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`)
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Auto-compaction triggers at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Transcripts persist independently of main conversation compaction

### Plugin Subagent Restrictions

Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` frontmatter fields. These fields are ignored when loading agents from a plugin. Copy the agent file to `.claude/agents/` or `~/.claude/agents/` if needed.

### CLI-Defined Subagents

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

The `--agents` flag accepts JSON with the same frontmatter fields. Use `prompt` for the system prompt (equivalent to the markdown body in file-based subagents).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create Custom Subagents](references/claude-code-sub-agents.md) -- Full guide covering built-in subagents, configuration, frontmatter fields, tool control, hooks, memory, invocation patterns, and example subagents

## Sources

- Create Custom Subagents: https://code.claude.com/docs/en/sub-agents.md
