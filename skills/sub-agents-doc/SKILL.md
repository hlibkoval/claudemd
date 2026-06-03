---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents: creating and configuring custom subagents, built-in agents, scope/priority, frontmatter fields, tool control, permission modes, hooks, persistent memory, forked subagents, and common patterns.

## Quick Reference

### Built-in Subagents

| Agent | Model | Tools | Purpose |
|:------|:------|:------|:--------|
| `Explore` | Haiku | Read-only | Fast codebase search; skips CLAUDE.md and git status |
| `Plan` | Inherits | Read-only | Research during plan mode; skips CLAUDE.md and git status |
| `general-purpose` | Inherits | All | Complex multi-step tasks requiring exploration + modification |
| `statusline-setup` | Sonnet | — | Configures status line via `/statusline` |
| `claude-code-guide` | Haiku | — | Answers questions about Claude Code features |

### Subagent Scope and Priority

| Location | Scope | Priority |
|:---------|:------|:---------|
| Managed settings | Organization-wide | 1 (highest) |
| `--agents` CLI flag | Current session only | 2 |
| `.claude/agents/` | Current project | 3 |
| `~/.claude/agents/` | All your projects | 4 |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest) |

When multiple subagents share the same name, the higher-priority location wins. Subagent files are discovered recursively within each scope directory.

### Subagent Frontmatter Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `name` | Yes | Unique identifier (lowercase letters and hyphens). Hooks receive this as `agent_type` |
| `description` | Yes | When Claude should delegate to this subagent |
| `tools` | No | Tool allowlist. Inherits all tools if omitted. Use `Agent(type)` to restrict spawnable subagents |
| `disallowedTools` | No | Tool denylist; removes from inherited or specified list |
| `model` | No | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default) |
| `permissionMode` | No | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan` |
| `maxTurns` | No | Maximum agentic turns before stopping |
| `skills` | No | Skills to preload into subagent context at startup |
| `mcpServers` | No | MCP servers scoped to this subagent (inline defs or name references) |
| `hooks` | No | Lifecycle hooks scoped to this subagent |
| `memory` | No | Persistent memory scope: `user`, `project`, or `local` |
| `background` | No | `true` to always run as a background task (default: `false`) |
| `effort` | No | Effort level override: `low`, `medium`, `high`, `xhigh`, `max` |
| `isolation` | No | `worktree` to run in a temporary git worktree |
| `color` | No | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan` |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main session via `--agent` |

### Model Resolution Order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter passed by Claude
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tools Unavailable to Subagents

These tools depend on main conversation state and cannot be used by subagents even when listed in `tools`:
`Agent`, `AskUserQuestion`, `EnterPlanMode`, `ExitPlanMode` (unless `permissionMode: plan`), `ScheduleWakeup`, `WaitForMcpServers`

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Standard permission checking with prompts |
| `acceptEdits` | Auto-accept file edits and common filesystem commands for working dir or additionalDirectories |
| `auto` | Background classifier reviews commands and protected-directory writes |
| `dontAsk` | Auto-deny permission prompts (explicitly allowed tools still work) |
| `bypassPermissions` | Skip all permission prompts (use with caution) |
| `plan` | Read-only plan mode |

Parent `bypassPermissions` or `acceptEdits` takes precedence and cannot be overridden. Parent `auto` mode cannot be overridden either; classifier evaluates subagent's tool calls with the same rules.

### Persistent Memory Scopes

| Scope | Location | Use when |
|:------|:---------|:---------|
| `user` | `~/.claude/agent-memory/<agent-name>/` | Knowledge spans all projects |
| `project` | `.claude/agent-memory/<agent-name>/` | Project-specific, shareable via version control (recommended default) |
| `local` | `.claude/agent-memory-local/<agent-name>/` | Project-specific, NOT checked into version control |

When memory is enabled, the first 200 lines or 25KB of `MEMORY.md` are included in the subagent's system prompt. Read, Write, and Edit tools are automatically enabled.

### What Loads at Startup (Non-Fork Subagents)

| Content | Loaded? | Exception |
|:--------|:--------|:---------|
| Subagent's own system prompt + environment details | Yes | Always |
| Delegation task message from Claude | Yes | Always |
| CLAUDE.md and memory hierarchy | Yes | Explore and Plan skip this |
| Git status snapshot | Yes | Explore and Plan skip this; also skipped if not a git repo or `includeGitInstructions: false` |
| Preloaded skills (from `skills` field) | Yes | Only skills listed in `skills` frontmatter |
| Parent conversation history | No | Forks only |

### Hooks for Subagents

**In subagent frontmatter** — run only while that subagent is active:

| Event | When it fires |
|:------|:-------------|
| `PreToolUse` | Before the subagent uses a tool |
| `PostToolUse` | After the subagent uses a tool |
| `Stop` | When the subagent finishes (converted to `SubagentStop` at runtime) |

**In `settings.json`** — run in the main session for subagent lifecycle events:

| Event | Matcher input | When it fires |
|:------|:-------------|:-------------|
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop` | Agent type name | When a subagent completes |

### Disabling Specific Subagents

In `settings.json`:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

Via CLI: `claude --disallowedTools "Agent(Explore)"`

### Invoking Subagents

| Method | When to use |
|:-------|:------------|
| Natural language ("Use the X subagent to...") | Claude decides whether to delegate |
| `@"subagent-name (agent)"` @-mention | Guarantees that specific subagent runs for one task |
| `claude --agent <name>` | Whole session runs as that subagent (replaces default system prompt) |
| `agent` key in `.claude/settings.json` | Default agent for every session in a project |

Plugin subagents appear in @-mention typeahead as `plugin-name:agent-name`. Disambiguate same-name agents: `claude --agent my-plugin:security-reviewer`.

### Foreground vs. Background Subagents

| Mode | Behavior |
|:-----|:---------|
| Foreground | Blocks main conversation; permission prompts passed through interactively |
| Background | Runs concurrently; auto-denies any tool call that would prompt |

Press `Ctrl+B` to background a running task. Set `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1` to disable all background task functionality.

### Fork Mode (Experimental, v2.1.117+)

Enable with `CLAUDE_CODE_FORK_SUBAGENT=1`. A fork inherits the full conversation history instead of starting fresh.

| | Fork | Named subagent |
|:---|:----|:--------------|
| Context | Full conversation history | Fresh context with delegated prompt |
| System prompt/tools | Same as main session | From subagent definition file |
| Prompt cache | Shared with main session | Separate cache |
| Permissions | Prompts surface in terminal | Auto-denied when in background |

Fork mode changes: (1) Claude uses forks instead of general-purpose for unspecified tasks; (2) all subagent spawns run in background; (3) `/fork` command spawns a fork (no longer an alias for `/branch`).

Fork panel keys: `↑`/`↓` to move between rows, `Enter` to open and send follow-up messages, `x` to dismiss/stop, `Esc` to return focus.

### Subagent Transcript Storage

Transcripts are stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`. Cleaned up after `cleanupPeriodDays` (default: 30 days). Auto-compaction triggers at ~95% capacity; override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`.

### Common Patterns

- **Isolate high-volume operations**: delegate log processing, test runs, or doc fetching so verbose output stays out of main context
- **Parallel research**: spawn multiple subagents for independent investigations, then synthesize
- **Chain subagents**: use subagents in sequence where each builds on the last's summary
- **Use main conversation** for iterative refinement, multi-phase tasks with shared context, or quick targeted changes

### CLI `--agents` Flag (JSON)

Pass JSON with the same frontmatter fields when launching. Use `prompt` (not a body) for the system prompt. Subagents exist for that session only:

```bash
claude --agents '{"code-reviewer": {"description": "...", "prompt": "...", "tools": ["Read", "Grep"], "model": "sonnet"}}'
```

### Plugin Subagents Security Restriction

Plugin subagents ignore the `hooks`, `mcpServers`, and `permissionMode` frontmatter fields. To use these, copy the agent file into `.claude/agents/` or `~/.claude/agents/`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Built-in subagents, quickstart, scope/priority, frontmatter fields, tool control, permission modes, persistent memory, hooks, fork mode, example subagents

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
