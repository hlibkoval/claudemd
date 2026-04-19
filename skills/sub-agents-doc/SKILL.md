---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating, configuring, and managing specialized AI subagents with custom system prompts, tool restrictions, permission modes, hooks, skills, MCP servers, persistent memory, and model selection.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them when a side task would flood the main conversation with verbose output (search results, logs, test output) that you won't reference again.

### When to use subagents vs alternatives

|                   | Subagents                                    | Main conversation                          | Agent teams                                   |
| :---------------- | :------------------------------------------- | :----------------------------------------- | :-------------------------------------------- |
| **Context**       | Own context window; summary returns to caller | Shared context                             | Fully independent sessions                    |
| **Best for**      | Focused tasks returning a summary            | Iterative work, quick changes              | Complex parallel work needing collaboration   |
| **Nesting**       | Cannot spawn other subagents                 | Can spawn subagents                        | Each teammate is independent                  |
| **Quick lookup**  | Use subagent                                 | Use `/btw` (no tools, answer discarded)    | Use agent teams                               |

### Built-in subagents

| Subagent           | Model   | Tools               | Purpose                                      |
| :----------------- | :------ | :------------------- | :-------------------------------------------- |
| **Explore**        | Haiku   | Read-only            | File discovery, code search, codebase exploration. Thoroughness: quick / medium / very thorough |
| **Plan**           | Inherit | Read-only            | Codebase research during plan mode            |
| **General-purpose**| Inherit | All                  | Complex research, multi-step operations, code modifications |
| **statusline-setup** | Sonnet | (helper)           | Runs when you use `/statusline`               |
| **Claude Code Guide** | Haiku | (helper)           | Answers questions about Claude Code features  |

### Subagent file format

Markdown files with YAML frontmatter. The body becomes the system prompt.

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide actionable feedback.
```

### Supported frontmatter fields

| Field             | Required | Description                                                                                  |
| :---------------- | :------- | :------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens)                                            |
| `description`     | Yes      | When Claude should delegate to this subagent                                                 |
| `tools`           | No       | Allowlist of tools. Inherits all if omitted                                                  |
| `disallowedTools` | No       | Denylist of tools, removed from inherited/specified list                                     |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`)                  |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                  |
| `maxTurns`        | No       | Max agentic turns before the subagent stops                                                  |
| `skills`          | No       | Skills to inject into context at startup (not inherited from parent)                         |
| `mcpServers`      | No       | MCP servers: inline definitions or string references to configured servers                   |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                      |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                      |
| `background`      | No       | `true` to always run as a background task (default: `false`)                                 |
| `effort`          | No       | Effort level: `low`, `medium`, `high`, `xhigh`, `max` (default: inherits from session)      |
| `isolation`       | No       | `worktree` for an isolated git worktree copy; auto-cleaned if no changes                     |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan`          |
| `initialPrompt`   | No       | Auto-submitted first user turn when running as main session agent via `--agent`              |

### Subagent scope and priority

| Location                     | Scope                   | Priority      |
| :--------------------------- | :---------------------- | :------------ |
| Managed settings             | Organization-wide       | 1 (highest)   |
| `--agents` CLI flag (JSON)   | Current session only    | 2             |
| `.claude/agents/`            | Current project         | 3             |
| `~/.claude/agents/`          | All your projects       | 4             |
| Plugin `agents/` directory   | Where plugin is enabled | 5 (lowest)    |

When multiple subagents share a name, the higher-priority location wins. Project subagents are discovered by walking up from cwd; `--add-dir` directories are NOT scanned.

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` env var
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool control

- **Allowlist**: `tools: Read, Grep, Glob, Bash` -- only these tools available
- **Denylist**: `disallowedTools: Write, Edit` -- inherits all except these
- If both set, `disallowedTools` applied first, then `tools` resolved against remaining pool
- `Agent(worker, researcher)` in `tools` restricts which subagent types can be spawned (main thread `--agent` only)
- Omitting `Agent` from `tools` entirely prevents spawning any subagents

### Permission modes

| Mode                | Behavior                                                          |
| :------------------ | :---------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                         |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands             |
| `auto`              | Background classifier reviews commands and protected writes       |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)|
| `bypassPermissions` | Skip permission prompts (use with caution)                        |
| `plan`              | Plan mode (read-only exploration)                                 |

Parent `bypassPermissions`, `acceptEdits`, or `auto` mode takes precedence and cannot be overridden by subagent frontmatter.

### Persistent memory

| Scope     | Location                                      | Use when                                                   |
| :-------- | :-------------------------------------------- | :--------------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects                 |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific, shareable via version control |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, should NOT be checked in                 |

When enabled, the subagent's system prompt includes instructions for reading/writing memory, and the first 200 lines or 25KB of `MEMORY.md` is preloaded. Read, Write, Edit tools are auto-enabled.

### MCP servers in subagents

Use `mcpServers` to scope MCP servers to a subagent. Inline definitions connect when the subagent starts and disconnect when it finishes. String references share the parent session's connection.

```yaml
mcpServers:
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  - github   # reuses already-configured server
```

### Hooks in subagent frontmatter

| Event         | Matcher input | When it fires                          |
| :------------ | :------------ | :------------------------------------- |
| `PreToolUse`  | Tool name     | Before the subagent uses a tool        |
| `PostToolUse` | Tool name     | After the subagent uses a tool         |
| `Stop`        | (none)        | When the subagent finishes (converted to `SubagentStop`) |

Project-level hooks in `settings.json` respond to `SubagentStart` and `SubagentStop` events (matched by agent type name).

### Invoking subagents

| Method                          | Effect                                                      |
| :------------------------------ | :---------------------------------------------------------- |
| Natural language (name it)      | Claude decides whether to delegate                          |
| `@"agent-name (agent)"`        | Guarantees that subagent runs for one task                  |
| `claude --agent <name>`        | Entire session uses that subagent's prompt, tools, and model |
| `agent` in `.claude/settings.json` | Default agent for every session in the project           |

### Foreground vs background

- **Foreground**: blocks main conversation; permission prompts and questions pass through
- **Background**: runs concurrently; permissions pre-approved before launch; questions auto-denied
- Ask Claude to "run this in the background" or press **Ctrl+B** to background a running task
- Disable via `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Resuming subagents

Ask Claude to continue a previously completed subagent. Claude uses `SendMessage` with the agent's ID to resume it with full context. Requires agent teams to be enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`). Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`.

### Auto-compaction

Subagents auto-compact at ~95% capacity (same logic as main conversation). Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (e.g., `50`).

### Disabling subagents

Add to `permissions.deny` in settings: `"Agent(Explore)"`, `"Agent(my-custom-agent)"`, or use `--disallowedTools "Agent(Explore)"`.

### Plugin subagent restrictions

Plugin subagents do NOT support `hooks`, `mcpServers`, or `permissionMode` frontmatter -- these fields are silently ignored. Copy the agent file to `.claude/agents/` or `~/.claude/agents/` if you need them.

### CLI-defined subagents (JSON)

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

Accepts all frontmatter fields; use `prompt` for the system prompt (equivalent to markdown body).

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, creating subagents via `/agents` or markdown files, all frontmatter fields, model selection, tool control, permission modes, MCP scoping, hooks, persistent memory, skills injection, foreground/background execution, resuming subagents, auto-compaction, and example subagent configurations.

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
