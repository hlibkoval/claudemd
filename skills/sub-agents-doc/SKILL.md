---
name: sub-agents-doc
description: Complete documentation for Claude Code subagents -- creating, configuring, and using specialized AI subagents for task-specific workflows and context management. Covers built-in subagents (Explore with Haiku for read-only codebase search, Plan for plan-mode research, general-purpose for complex multi-step tasks, Bash/statusline-setup/Claude Code Guide helpers), quickstart with /agents command (create/edit/delete subagents, guided setup, Claude generation), subagent scopes and priority (--agents CLI flag highest, .claude/agents/ project, ~/.claude/agents/ user, plugin agents/ lowest), writing subagent files (Markdown with YAML frontmatter, body becomes system prompt), supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model selection (sonnet/opus/haiku aliases, full model IDs, inherit, CLAUDE_CODE_SUBAGENT_MODEL env var override, per-invocation model parameter, resolution order), tool control (tools allowlist, disallowedTools denylist, Agent(agent_type) to restrict spawnable subagents, disallowedTools applied first then tools resolved), MCP server scoping (inline definitions scoped to subagent, string references to existing servers), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan, parent bypassPermissions takes precedence, auto mode inherited), preloading skills into subagents (skills field injects full content at startup, subagents do not inherit parent skills), persistent memory (memory field with user/project/local scopes, MEMORY.md auto-included, memory directory paths), hooks in subagent frontmatter (PreToolUse, PostToolUse, Stop converted to SubagentStop), project-level hooks for subagent events (SubagentStart, SubagentStop in settings.json with matchers), automatic delegation (based on description field, task description, current context), explicit invocation (natural language naming, @-mention with typeahead, --agent flag for session-wide, agent setting in .claude/settings.json), foreground vs background subagents (blocking vs concurrent, Ctrl+B to background, pre-approved permissions for background, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS env var), common patterns (isolate high-volume operations, parallel research, chain subagents), choosing between subagents and main conversation (context preservation vs back-and-forth needs), resume subagents (SendMessage tool with agent ID, requires agent teams enabled, full context retained, transcript files at ~/.claude/projects/{project}/{sessionId}/subagents/), auto-compaction (95% capacity default, CLAUDE_AUTOCOMPACT_PCT_OVERRIDE), subagent transcript persistence (separate from main conversation, survive compaction, cleanupPeriodDays setting), example subagents (code-reviewer read-only, debugger with edit access, data-scientist with model override, db-reader with PreToolUse hook validation), disabling subagents (permissions.deny with Agent(name) format, --disallowedTools CLI flag), plugin subagents (no hooks/mcpServers/permissionMode support for security), subagent definitions reusable as agent team teammates. Load when discussing Claude Code subagents, custom agents, task delegation, Agent tool, subagent configuration, subagent tools, subagent permissions, subagent hooks, subagent memory, subagent models, background tasks, foreground tasks, Explore agent, Plan agent, general-purpose agent, /agents command, agent scopes, subagent isolation, worktree isolation, subagent skills preloading, subagent MCP servers, subagent resume, or any subagent-related topic for Claude Code.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents -- creating, configuring, and using specialized AI subagents for task-specific workflows and improved context management.

## Quick Reference

### Built-in Subagents

| Subagent | Model | Tools | Purpose |
|:---------|:------|:------|:--------|
| **Explore** | Haiku | Read-only (no Write/Edit) | File discovery, code search, codebase exploration |
| **Plan** | Inherits | Read-only (no Write/Edit) | Codebase research for planning (used in plan mode) |
| **general-purpose** | Inherits | All tools | Complex research, multi-step operations, code modifications |
| **Bash** | Inherits | Terminal commands | Running terminal commands in separate context |
| **statusline-setup** | Sonnet | -- | Configuring status line via /statusline |
| **Claude Code Guide** | Haiku | -- | Answering questions about Claude Code features |

Explore uses three thoroughness levels: **quick** (targeted lookups), **medium** (balanced), **very thorough** (comprehensive).

### Subagent File Format

Markdown files with YAML frontmatter. Body becomes the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

### Supported Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens) |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Allowlist of tools; inherits all if omitted |
| `disallowedTools` | No | Tools to deny (removed from inherited or specified list) |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to inject into subagent context at startup |
| `mcpServers` | No | MCP servers (inline definitions or string references) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as background task (default: `false`) |
| `effort` | No | `low`, `medium`, `high`, `max` (Opus 4.6 only) |
| `isolation` | No | `worktree` for temporary git worktree isolation |
| `initialPrompt` | No | Auto-submitted first user turn when running as main agent via `--agent` |

### Subagent Scopes (Priority Order)

| Priority | Location | Scope |
|:---------|:---------|:------|
| 1 (highest) | `--agents` CLI flag | Current session only (JSON, not saved to disk) |
| 2 | `.claude/agents/` | Current project (check into version control) |
| 3 | `~/.claude/agents/` | All user projects |
| 4 (lowest) | Plugin `agents/` directory | Where plugin is enabled |

When multiple subagents share the same name, the higher-priority location wins.

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable (if set)
2. Per-invocation `model` parameter (Claude chooses at runtime)
3. Subagent definition `model` frontmatter
4. Main conversation's model

### Tool Control

- **`tools`**: Allowlist -- only these tools are available
- **`disallowedTools`**: Denylist -- removed from inherited set
- If both set: `disallowedTools` applied first, then `tools` resolved against remaining
- **`Agent(agent_type)`** in `tools`: Restricts which subagents can be spawned (only for `--agent` main thread)
- Omitting `Agent` from tools prevents spawning any subagents

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

Inline servers connect when subagent starts and disconnect when it finishes. Keeps MCP tool descriptions out of main conversation context.

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits |
| `dontAsk` | Auto-deny prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip permission prompts (use with caution) |
| `plan` | Plan mode (read-only exploration) |

Parent `bypassPermissions` takes precedence and cannot be overridden. Parent auto mode is inherited and overrides subagent `permissionMode`.

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<name>/` | Learnings apply across all projects |
| `project` | `.claude/agent-memory/<name>/` | Knowledge is project-specific and shareable via VCS |
| `local` | `.claude/agent-memory-local/<name>/` | Project-specific but not checked into VCS |

When enabled: system prompt includes memory instructions, first 200 lines or 25KB of `MEMORY.md` auto-included, Read/Write/Edit tools auto-enabled.

### Hooks

**In subagent frontmatter** (runs only while subagent is active):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `PreToolUse` | Tool name | Before the subagent uses a tool |
| `PostToolUse` | Tool name | After the subagent uses a tool |
| `Stop` | (none) | When subagent finishes (converted to `SubagentStop`) |

**In settings.json** (main session events):

| Event | Matcher input | When it fires |
|:------|:-------------|:--------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Invoking Subagents

| Method | Behavior |
|:-------|:---------|
| Natural language (name in prompt) | Claude decides whether to delegate |
| @-mention (`@"name (agent)"`) | Guarantees that subagent runs for one task |
| `--agent <name>` CLI flag | Whole session uses subagent's prompt, tools, model |
| `agent` in `.claude/settings.json` | Default agent for every session in project |

Plugin subagents: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs Background

| Aspect | Foreground | Background |
|:-------|:-----------|:-----------|
| Blocking | Yes | No (concurrent) |
| Permission prompts | Passed through to user | Pre-approved before launch; auto-denied otherwise |
| Clarifying questions | Passed through | Fail (subagent continues) |
| Start background | Ask Claude or press **Ctrl+B** | -- |
| Disable background | Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` | -- |

### Resuming Subagents

Requires agent teams enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` or `--agent-teams` flag). Uses `SendMessage` tool with agent ID. Full context retained from previous conversation. Transcript files at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

### Auto-Compaction

Triggers at ~95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50` for 50%). Transcripts persist independently of main conversation compaction.

### Disabling Subagents

Add to `permissions.deny` in settings:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

Or via CLI: `claude --disallowedTools "Agent(Explore)"`

### Plugin Subagent Restrictions

Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` fields (ignored for security). Copy the agent file to `.claude/agents/` or `~/.claude/agents/` if you need these features.

### Key Constraints

- Subagents **cannot** spawn other subagents (no nesting)
- Subagents receive only their system prompt plus basic environment details, not the full Claude Code system prompt
- Subagents do not inherit skills from parent; use `skills` field explicitly
- Subagents loaded at session start; restart session or use `/agents` to load new files
- Directories added with `--add-dir` are not scanned for subagents

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) -- Built-in subagents (Explore, Plan, general-purpose, Bash, statusline-setup, Claude Code Guide), quickstart with /agents command, subagent scopes and priority (CLI flag, project, user, plugin), writing subagent files (Markdown with YAML frontmatter), supported frontmatter fields (name, description, tools, disallowedTools, model, permissionMode, maxTurns, skills, mcpServers, hooks, memory, background, effort, isolation, initialPrompt), model selection and resolution order, tool control (allowlists, denylists, Agent(agent_type) restrictions), MCP server scoping (inline and reference), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan), preloading skills, persistent memory (user/project/local scopes), hooks in frontmatter and settings.json (PreToolUse, PostToolUse, Stop, SubagentStart, SubagentStop), automatic and explicit delegation (@-mention, --agent flag, agent setting), foreground vs background subagents (Ctrl+B, CLAUDE_CODE_DISABLE_BACKGROUND_TASKS), common patterns (isolate high-volume operations, parallel research, chain subagents), choosing between subagents and main conversation, resuming subagents (SendMessage, agent teams required), auto-compaction, transcript persistence, example subagents (code-reviewer, debugger, data-scientist, db-reader with PreToolUse hook), disabling subagents (permissions.deny, --disallowedTools), plugin subagent restrictions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
