---
name: sub-agents-doc
description: Complete official documentation for Claude Code subagents — creating and configuring custom subagents, built-in subagents, frontmatter fields, tool access, permission modes, hooks, persistent memory, model selection, invocation patterns, and example subagents.
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, specific tool access, and independent permissions. Use them to keep verbose output out of your main conversation, enforce tool constraints, or reuse configurations across projects.

### Built-in subagents

| Agent              | Model   | Tools         | Purpose                                          |
| :----------------- | :------ | :------------ | :----------------------------------------------- |
| `Explore`          | Haiku   | Read-only     | File discovery, code search, codebase exploration |
| `Plan`             | Inherit | Read-only     | Codebase research during plan mode               |
| `general-purpose`  | Inherit | All tools     | Complex multi-step tasks requiring exploration + action |
| `statusline-setup` | Sonnet  | —             | Configures your status line when `/statusline` runs |
| `Claude Code Guide`| Haiku   | —             | Answers questions about Claude Code features     |

### Subagent scope and priority

| Location                      | Scope                   | Priority    |
| :---------------------------- | :---------------------- | :---------- |
| Managed settings              | Organization-wide       | 1 (highest) |
| `--agents` CLI flag           | Current session only    | 2           |
| `.claude/agents/`             | Current project         | 3           |
| `~/.claude/agents/`           | All your projects       | 4           |
| Plugin's `agents/` directory  | Where plugin is enabled | 5 (lowest)  |

When names conflict, higher-priority location wins. List all configured subagents from the CLI (without a session) with `claude agents`.

### Supported frontmatter fields

Only `name` and `description` are required.

| Field             | Required | Notes                                                                                       |
| :---------------- | :------- | :------------------------------------------------------------------------------------------ |
| `name`            | Yes      | Unique identifier: lowercase letters and hyphens                                            |
| `description`     | Yes      | When Claude should delegate to this subagent                                                |
| `tools`           | No       | Allowlist of tools; inherits all tools if omitted                                           |
| `disallowedTools` | No       | Denylist applied before `tools` resolution; a tool in both is removed                      |
| `model`           | No       | `sonnet`, `opus`, `haiku`, full model ID (e.g. `claude-opus-4-7`), or `inherit` (default)  |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                |
| `maxTurns`        | No       | Maximum agentic turns before stopping                                                       |
| `skills`          | No       | Skills to inject at startup (full content, not just available for invocation)               |
| `mcpServers`      | No       | Inline MCP server definitions or names of already-configured servers                       |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                     |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                     |
| `background`      | No       | `true` to always run as a background task (default: `false`)                                |
| `effort`          | No       | `low`, `medium`, `high`, `xhigh`, or `max`; overrides session effort level                  |
| `isolation`       | No       | `worktree` to run in a temporary git worktree (cleaned up if no changes)                    |
| `color`           | No       | `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                    |
| `initialPrompt`   | No       | Auto-submitted as first user turn when running as main session agent via `--agent`          |

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission modes

| Mode                | Behavior                                                                                     |
| :------------------ | :------------------------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                                    |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands for paths in the working directory     |
| `auto`              | Background classifier reviews commands and protected-directory writes                        |
| `dontAsk`           | Auto-deny permission prompts (explicitly allowed tools still work)                           |
| `bypassPermissions` | Skip permission prompts (use with caution; `.git`, `.claude`, `.vscode` still prompt)        |
| `plan`              | Read-only exploration                                                                        |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence. If the parent uses auto mode, the subagent inherits auto mode and its `permissionMode` frontmatter is ignored.

### Persistent memory scopes

| Scope     | Location                                      | Use when                                            |
| :-------- | :-------------------------------------------- | :-------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`              | Knowledge applies across all projects               |
| `project` | `.claude/agent-memory/<name>/`                | Project-specific, shareable via version control     |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific, not checked into version control  |

When memory is enabled: Read, Write, and Edit tools are auto-enabled; the first 200 lines or 25KB of `MEMORY.md` is injected into the subagent's system prompt.

### Hook events for subagents

**In subagent frontmatter** (fires only while that subagent is active):

| Event         | When it fires                                                         |
| :------------ | :-------------------------------------------------------------------- |
| `PreToolUse`  | Before the subagent uses a tool                                       |
| `PostToolUse` | After the subagent uses a tool                                        |
| `Stop`        | When the subagent finishes (converted to `SubagentStop` at runtime)   |

**In `settings.json`** (fires in the main session for subagent lifecycle events):

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invocation patterns

| Pattern          | How to use                                                                   |
| :--------------- | :--------------------------------------------------------------------------- |
| Natural language | Name the subagent in your prompt; Claude decides whether to delegate         |
| @-mention        | `@"code-reviewer (agent)"` — guarantees that subagent runs for one task      |
| `--agent` flag   | `claude --agent code-reviewer` — whole session uses that subagent's config   |
| `agent` setting  | Set `"agent": "code-reviewer"` in `.claude/settings.json` for session default |

For plugin subagents: `@agent-<plugin-name>:<agent-name>` or `claude --agent <plugin-name>:<agent-name>`.

### Foreground vs background

- **Foreground** (default): blocks main conversation; permission prompts and `AskUserQuestion` pass through
- **Background**: runs concurrently; permissions pre-approved at launch; clarifying question tool calls fail silently
- Press **Ctrl+B** to background a running task
- Disable all background tasks: `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`

### Subagents vs main conversation

Use **subagents** when the task produces verbose output you don't need in context, needs specific tool restrictions, or is self-contained. Use the **main conversation** for iterative back-and-forth, multi-phase work with shared context, or when latency matters (subagents start fresh). For reusable prompts that run in the main conversation, use [Skills](/en/skills) instead.

### Restricting which subagents can be spawned

Use `Agent(name)` syntax in the `tools` field (for `--agent` sessions) to allowlist which subagent types can be spawned:

```yaml
tools: Agent(worker, researcher), Read, Bash
```

To block specific agents without allowlisting, use `permissions.deny` in `settings.json`:

```json
{
  "permissions": {
    "deny": ["Agent(Explore)", "Agent(my-custom-agent)"]
  }
}
```

### CLI-defined subagents (session-only)

Pass JSON to `--agents` for subagents that exist only for that session:

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

The `prompt` key is equivalent to the markdown body in file-based subagents.

### Auto-compaction

Subagents compact at ~95% capacity by default. Override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`. Transcripts stored at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`, cleaned up per `cleanupPeriodDays` (default 30 days).

### Plugin subagent restrictions

Plugin subagents do **not** support `hooks`, `mcpServers`, or `permissionMode` frontmatter — those fields are ignored. Copy the file into `.claude/agents/` or `~/.claude/agents/` to use them.

### Best practices summary

- Write focused subagents that excel at one task
- Use detailed `description` fields — Claude uses them to decide when to delegate
- Limit tool access to only what the subagent needs
- Check project subagents (`.claude/agents/`) into version control
- Use `model: haiku` to reduce cost for fast, simple tasks

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — full guide covering built-in subagents, quickstart, all frontmatter fields, model selection, tool access, permission modes, MCP server scoping, hooks, persistent memory, invocation patterns (natural language, @-mention, --agent flag), foreground/background execution, context management, resuming subagents, auto-compaction, common patterns, and example subagents (code reviewer, debugger, data scientist, database query validator).

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
