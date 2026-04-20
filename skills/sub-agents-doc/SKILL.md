---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating, configuring, and managing specialized AI subagents with custom prompts, tool restrictions, permission modes, hooks, persistent memory, and model selection.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. They handle a task and return only the summary, keeping verbose output out of the main conversation. Define a custom subagent when you repeatedly spawn the same kind of worker with the same instructions.

### Built-in subagents

| Agent              | Model   | Tools             | Purpose                                      |
| :----------------- | :------ | :---------------- | :------------------------------------------- |
| **Explore**        | Haiku   | Read-only         | File discovery, code search, codebase exploration |
| **Plan**           | Inherit | Read-only         | Codebase research during plan mode           |
| **General-purpose**| Inherit | All               | Complex research, multi-step operations, code modifications |
| **statusline-setup** | Sonnet | —               | `/statusline` configuration                  |
| **Claude Code Guide** | Haiku | —               | Questions about Claude Code features         |

Explore supports a thoroughness level: **quick**, **medium**, or **very thorough**.

### Subagent file locations (priority order)

| Location                     | Scope               | Priority    |
| :--------------------------- | :------------------- | :---------- |
| Managed settings             | Organization-wide    | 1 (highest) |
| `--agents` CLI flag          | Current session      | 2           |
| `.claude/agents/`            | Current project      | 3           |
| `~/.claude/agents/`          | All your projects    | 4           |
| Plugin `agents/` directory   | Where plugin enabled | 5 (lowest)  |

When multiple subagents share the same name, the higher-priority location wins. Project subagents are discovered by walking up from cwd. `--add-dir` directories are NOT scanned for subagents.

### Subagent file format

Markdown with YAML frontmatter for configuration; the body becomes the system prompt:

```markdown
---
name: code-reviewer
description: Reviews code for quality and best practices
tools: Read, Glob, Grep
model: sonnet
---

You are a code reviewer. Analyze code and provide feedback.
```

### Supported frontmatter fields

| Field             | Required | Description                                                                   |
| :---------------- | :------- | :---------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens)                             |
| `description`     | Yes      | When Claude should delegate to this subagent                                  |
| `tools`           | No       | Allowlist of tools; inherits all if omitted                                   |
| `disallowedTools` | No       | Denylist; removed from inherited or specified list                            |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` (default: `inherit`)   |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`   |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                               |
| `skills`          | No       | Skills to inject into context at startup (full content, not just available)    |
| `mcpServers`      | No       | MCP servers: string references or inline definitions                          |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                       |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                        |
| `background`      | No       | `true` to always run as a background task (default: `false`)                  |
| `effort`          | No       | Override session effort: `low`, `medium`, `high`, `xhigh`, `max`             |
| `isolation`       | No       | `worktree` for an isolated git worktree copy                                  |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, `cyan` |
| `initialPrompt`   | No       | Auto-submitted first user turn when running as main session agent             |

**Plugin subagents** do NOT support `hooks`, `mcpServers`, or `permissionMode` (ignored for security).

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` env var
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Tool control

- **Allowlist** (`tools`): only listed tools available; no others
- **Denylist** (`disallowedTools`): inherit everything except listed tools
- If both set: `disallowedTools` applied first, then `tools` resolved against remainder
- Use `Agent(worker, researcher)` in `tools` to restrict which subagent types can be spawned (only when running as main agent via `--agent`)
- Omit `Agent` from `tools` entirely to prevent spawning any subagents

### Permission modes

| Mode                | Behavior                                                                   |
| :------------------ | :------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                  |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands in working dir       |
| `auto`              | Background classifier reviews commands and protected-directory writes      |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)         |
| `bypassPermissions` | Skip permission prompts (use with caution)                                 |
| `plan`              | Read-only exploration                                                      |

Parent `bypassPermissions`, `acceptEdits`, or `auto` modes take precedence and cannot be overridden by the subagent.

### MCP servers in subagents

Use `mcpServers` to scope MCP servers to a subagent. Two forms:

```yaml
mcpServers:
  # Inline definition: connected on start, disconnected on finish
  - playwright:
      type: stdio
      command: npx
      args: ["-y", "@playwright/mcp@latest"]
  # String reference: reuses already-configured server
  - github
```

Inline definitions keep MCP tool descriptions out of the main conversation context.

### Persistent memory

| Scope     | Location                                      | Use when                                          |
| :-------- | :-------------------------------------------- | :------------------------------------------------ |
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings apply across all projects               |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via version control   |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked into version control |

When enabled: `MEMORY.md` (first 200 lines / 25KB) loads each session; Read, Write, Edit tools auto-enabled.

### Hooks in subagents

**In frontmatter** (run only while subagent is active):

| Event         | Matcher   | When it fires                    |
| :------------ | :-------- | :------------------------------- |
| `PreToolUse`  | Tool name | Before the subagent uses a tool  |
| `PostToolUse` | Tool name | After the subagent uses a tool   |
| `Stop`        | (none)    | When the subagent finishes       |

`Stop` hooks in frontmatter auto-convert to `SubagentStop` at runtime. Frontmatter hooks fire only when spawned as a subagent (not via `--agent`).

**In settings.json** (project-level subagent lifecycle events):

| Event           | Matcher         | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invoking subagents

| Method              | How                                                                  |
| :------------------ | :------------------------------------------------------------------- |
| Automatic           | Claude delegates based on task and subagent `description`            |
| Natural language    | Name the subagent in your prompt                                     |
| @-mention           | `@"code-reviewer (agent)"` guarantees that subagent runs            |
| Session-wide        | `claude --agent code-reviewer` or `"agent": "code-reviewer"` in settings |
| Plugin subagent     | `claude --agent plugin-name:agent-name`                              |

### Foreground vs background

| Mode         | Permission handling                            | Clarifying questions                      |
| :----------- | :--------------------------------------------- | :---------------------------------------- |
| Foreground   | Prompts pass through to user                   | Passed through to user                    |
| Background   | Pre-approved before launch; auto-deny the rest | Tool call fails, subagent continues       |

Background a running task with **Ctrl+B**. Disable background tasks with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Disabling subagents

Add to `permissions.deny` in settings or use the CLI flag:

```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-custom-agent)"] } }
```

```bash
claude --disallowedTools "Agent(Explore)"
```

### Context management

- Subagents cannot spawn other subagents
- Auto-compaction at ~95% capacity (override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`)
- Resume a subagent by asking Claude to continue previous work (requires agent teams enabled for `SendMessage`)
- Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`
- Transcripts cleaned up after `cleanupPeriodDays` (default: 30)

### CLI-defined subagents (session-only)

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer",
    "prompt": "You are a senior code reviewer.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

Accepts same fields as file-based frontmatter; use `prompt` for the system prompt body.

### When to use subagents vs alternatives

| Situation                                         | Use                   |
| :------------------------------------------------ | :-------------------- |
| Task produces verbose output you don't need later  | Subagent              |
| Enforce specific tool restrictions or permissions  | Subagent              |
| Self-contained work returning a summary            | Subagent              |
| Quick question using current context, no tools     | `/btw`                |
| Reusable prompt running in main conversation       | Skill                 |
| Multiple agents needing discussion and collaboration | Agent team          |
| Frequent back-and-forth or iterative refinement    | Main conversation     |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, creating subagents via `/agents` or manually, all frontmatter fields, model selection, tool control, permission modes, MCP server scoping, skills injection, persistent memory, hooks, foreground/background execution, invoking subagents, context management, and example subagent configurations (code reviewer, debugger, data scientist, database query validator).

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
