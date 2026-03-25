---
name: sub-agents-doc
description: Complete documentation for Claude Code custom subagents -- creating, configuring, and managing specialized AI subagents. Covers subagent file format (Markdown with YAML frontmatter), supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation), built-in subagents (Explore, Plan, General-purpose, Bash, statusline-setup, Claude Code Guide), subagent scopes and priority (--agents CLI flag, .claude/agents/, ~/.claude/agents/, plugin agents/), model selection (sonnet/opus/haiku aliases, full model IDs, inherit), tool control (allowlist with tools field, denylist with disallowedTools field, Agent(type) syntax for restricting spawnable subagents), MCP server scoping (inline definitions and named references), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), skill preloading (skills field injects full content), persistent memory (user/project/local scopes, MEMORY.md), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop events), project-level hooks (SubagentStart, SubagentStop events), automatic and explicit delegation (natural language, @-mention, --agent flag, agent setting), foreground vs background execution (Ctrl+B, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), subagent resume (SendMessage with agent ID), auto-compaction (CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), common patterns (isolate high-volume operations, parallel research, chaining subagents), disabling subagents (permissions.deny with Agent(name)), /agents command, claude agents CLI. Load when discussing Claude Code subagents, custom agents, agent delegation, spawning subagents, /agents command, --agent flag, agent frontmatter, subagent tools, subagent model, subagent permissions, subagent hooks, subagent memory, subagent MCP servers, subagent skills, background tasks, foreground tasks, agent isolation, worktree isolation, Agent tool, Task tool, agent teams vs subagents, built-in agents, Explore agent, Plan agent, resuming subagents, subagent compaction, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code custom subagents -- creating, configuring, and managing specialized AI subagents that handle task-specific workflows with independent context.

## Quick Reference

### What Subagents Do

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. They preserve main conversation context, enforce constraints, specialize behavior, and can use faster/cheaper models.

Subagents cannot spawn other subagents. For multi-agent parallelism with independent contexts, use agent teams instead.

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for plan mode |
| **General-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal commands | Running terminal commands in separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via `/statusline` |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore uses three thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive).

### Subagent File Format

Markdown file with YAML frontmatter. Body becomes the system prompt. Subagents receive only this prompt plus basic environment details, not the full Claude Code system prompt.

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier, lowercase letters and hyphens |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Denylist, removed from inherited or specified set |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID (e.g. `claude-opus-4-6`), or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | No | Maximum agentic turns before subagent stops |
| `skills` | No | Skills to inject into context at startup (full content, not just available) |
| `mcpServers` | No | MCP servers: inline definitions or string references to existing servers |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only); overrides session level |
| `isolation` | No | `worktree` for temporary git worktree with isolated repo copy |

### Subagent Scopes and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| `--agents` CLI flag (JSON) | Current session only | 1 (highest) |
| `.claude/agents/` | Current project | 2 |
| `~/.claude/agents/` | All user projects | 3 |
| Plugin `agents/` directory | Where plugin is enabled | 4 (lowest) |

When multiple subagents share the same name, the higher-priority location wins.

### Tool Control

**Allowlist** (`tools` field): Only these tools are available. Subagent cannot use anything else.

**Denylist** (`disallowedTools` field): Inherits all tools except these. If both fields are set, `disallowedTools` is applied first, then `tools` resolves against the remaining pool.

**Restrict spawnable subagents** (main-thread agents via `--agent` only): Use `Agent(worker, researcher)` in `tools` to allow spawning only named types. Use `Agent` without parentheses for unrestricted spawning. Omit `Agent` entirely to prevent spawning. This has no effect in subagent definitions (subagents cannot spawn subagents).

### MCP Server Scoping

The `mcpServers` field accepts a list of entries, each either:
- **Inline definition**: server name as key with full MCP config as value (connected on start, disconnected on finish)
- **String reference**: name of an already-configured server (shares parent session connection)

Inline servers keep their tool descriptions out of the parent conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (writes to .git, .claude, .vscode, .idea still prompt) |
| `plan` | Plan mode (read-only exploration) |

Parent `bypassPermissions` takes precedence and cannot be overridden. Parent auto mode is inherited; subagent `permissionMode` is ignored.

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Project-specific, shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific, not checked in |

When enabled: system prompt includes memory instructions, first 200 lines of `MEMORY.md` are loaded, Read/Write/Edit tools are auto-enabled.

### Hooks in Subagent Frontmatter

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When the subagent finishes (converted to `SubagentStop` at runtime) |

All standard hook events are supported. Hook types: `command` (shell), `http`, `prompt`, `agent`.

### Project-Level Hooks for Subagent Events

Configured in `settings.json`, not in subagent frontmatter:

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| **Natural language** | Name the subagent in prompt; Claude decides whether to delegate |
| **@-mention** | `@"code-reviewer (agent)"` guarantees that subagent runs for one task |
| **`--agent` flag** | Entire session uses that subagent's prompt, tools, and model |
| **`agent` setting** | Set in `.claude/settings.json` for project-wide default |

Plugin subagents use scoped name: `@agent-<plugin>:<agent>` or `claude --agent <plugin>:<agent>`.

### Foreground vs Background

| Mode | Permission prompts | Clarifying questions | Concurrency |
|:-----|:-------------------|:---------------------|:------------|
| **Foreground** | Passed through to user | Supported | Blocking |
| **Background** | Pre-approved before launch; auto-denied at runtime | Fail (subagent continues) | Concurrent |

Press **Ctrl+B** to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable background tasks.

### Resuming Subagents

Each invocation creates a new instance with fresh context. To continue existing work, ask Claude to resume -- it uses `SendMessage` with the agent ID to restore full conversation history. Subagent transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

Subagent transcripts are unaffected by main conversation compaction. Auto-compaction triggers at ~95% capacity (configurable via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`).

### Disabling Subagents

Add `Agent(<name>)` to `permissions.deny` in settings, or use `--disallowedTools "Agent(Explore)"` CLI flag. Works for both built-in and custom subagents.

### Managing Subagents

| Action | How |
|:-------|:----|
| List/create/edit/delete interactively | `/agents` command |
| List from CLI without interactive session | `claude agents` |
| Define session-only subagents | `--agents '{...}'` flag with JSON |
| Reload after manual file changes | Restart session or use `/agents` |

### Plugin Subagent Restrictions

Plugin subagents do not support `hooks`, `mcpServers`, or `permissionMode` fields (ignored on load). Copy the agent file to `.claude/agents/` or `~/.claude/agents/` if you need these features.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- creating and configuring subagents; built-in subagents (Explore, Plan, General-purpose); /agents command; subagent scopes and priority; writing subagent files; supported frontmatter fields; model selection; tool control (allowlist, denylist, Agent(type) restriction); MCP server scoping; permission modes; skill preloading; persistent memory; hooks in frontmatter and settings.json; automatic and explicit delegation; @-mention and --agent flag; foreground vs background execution; common patterns (isolating high-volume ops, parallel research, chaining); resuming subagents; auto-compaction; disabling subagents; example subagents (code reviewer, debugger, data scientist, database query validator)

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
