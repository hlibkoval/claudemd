---
name: sub-agents-doc
user-invocable: false
---

# Sub-Agents Documentation

This skill provides the complete official documentation for Claude Code sub-agents.

## Quick Reference

### Built-in subagents

| Agent             | Model    | Purpose                                                  | Loads CLAUDE.md / git status |
| :---------------- | :------- | :------------------------------------------------------- | :--------------------------- |
| Explore           | Haiku    | Read-only codebase search and analysis                   | No                           |
| Plan              | Inherits | Read-only research during plan mode                      | No                           |
| General-purpose   | Inherits | Complex multi-step tasks requiring exploration + action  | Yes                          |
| statusline-setup  | Sonnet   | Configures the status line when you run `/statusline`    | Yes                          |
| claude-code-guide | Haiku    | Answers questions about Claude Code features             | Yes                          |

### Subagent scope and priority

| Location                     | Scope             | Priority    |
| :--------------------------- | :---------------- | :---------- |
| Managed settings             | Organization-wide | 1 (highest) |
| `--agents` CLI flag          | Current session   | 2           |
| `.claude/agents/`            | Current project   | 3           |
| `~/.claude/agents/`          | All projects      | 4           |
| Plugin's `agents/` directory | Plugin scope      | 5 (lowest)  |

### Supported frontmatter fields

| Field             | Required | Description                                                                                             |
| :---------------- | :------- | :------------------------------------------------------------------------------------------------------ |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens). Hooks receive this as `agent_type`                  |
| `description`     | Yes      | When Claude should delegate to this subagent                                                            |
| `tools`           | No       | Allowlist of tools; inherits all if omitted. Use `Agent(type1,type2)` to restrict spawnable subagents  |
| `disallowedTools` | No       | Denylist removed from inherited or specified list                                                       |
| `model`           | No       | `sonnet`, `opus`, `haiku`, `fable`, full model ID, or `inherit` (default)                              |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`. Ignored for plugin agents |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                                                         |
| `skills`          | No       | Skills to preload into the subagent's context at startup (full content injected)                        |
| `mcpServers`      | No       | MCP servers available; inline definitions or string references. Ignored for plugin agents               |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent. Ignored for plugin agents                                      |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                                  |
| `background`      | No       | Set `true` to always run as a background task (default: `false`)                                        |
| `effort`          | No       | Effort level override: `low`, `medium`, `high`, `xhigh`, `max`                                         |
| `isolation`       | No       | Set to `worktree` to run in a temporary git worktree                                                    |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                 |
| `initialPrompt`   | No       | Auto-submitted first user turn when running as main session agent via `--agent`                         |

### Model resolution order

1. `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. Per-invocation `model` parameter
3. Subagent definition's `model` frontmatter
4. Main conversation's model

### Permission modes

| Mode                | Behavior                                                             |
| :------------------ | :------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                            |
| `acceptEdits`       | Auto-accept file edits for paths in working dir / additionalDirs     |
| `auto`              | Background classifier reviews commands and protected-directory writes |
| `dontAsk`           | Auto-deny permission prompts (explicit allow rules still work)       |
| `bypassPermissions` | Skip all permission prompts (use with caution)                       |
| `plan`              | Read-only exploration (plan mode)                                    |

If the parent uses `bypassPermissions` or `acceptEdits`, it takes precedence and cannot be overridden by the subagent.

### Persistent memory scopes

| Scope     | Location                                      | Use when                                            |
| :-------- | :-------------------------------------------- | :-------------------------------------------------- |
| `user`    | `~/.claude/agent-memory/<name>/`              | Learnings should apply across all projects          |
| `project` | `.claude/agent-memory/<name>/`                | Knowledge is project-specific and shareable via VCS |
| `local`   | `.claude/agent-memory-local/<name>/`          | Project-specific but not to be committed            |

### Tools unavailable to subagents

Even when listed in `tools`, these are not available to subagents:
- `Agent`, `AskUserQuestion`, `EnterPlanMode`, `ScheduleWakeup`, `WaitForMcpServers`
- `ExitPlanMode` (unless subagent's `permissionMode` is `plan`)

### Hook events in subagent frontmatter

| Event         | Matcher input | When it fires                                               |
| :------------ | :------------ | :---------------------------------------------------------- |
| `PreToolUse`  | Tool name     | Before the subagent uses a tool                             |
| `PostToolUse` | Tool name     | After the subagent uses a tool                              |
| `Stop`        | (none)        | When the subagent finishes (converted to `SubagentStop`)    |

### Project-level hook events (settings.json)

| Event           | Matcher input   | When it fires                    |
| :-------------- | :-------------- | :------------------------------- |
| `SubagentStart` | Agent type name | When a subagent begins execution |
| `SubagentStop`  | Agent type name | When a subagent completes        |

### Invocation methods

- **Natural language**: Name the subagent in your prompt; Claude decides whether to delegate.
- **@-mention**: Type `@` and pick from typeahead to guarantee that subagent runs for one task.
- **`--agent <name>` flag**: Run the whole session using that subagent's system prompt, tools, and model.
- **`agent` setting in `.claude/settings.json`**: Makes a subagent the default for every session in a project.

### Fork subagents (v2.1.117+)

A fork inherits the entire conversation history instead of starting fresh. Enable with `CLAUDE_CODE_FORK_SUBAGENT=1` or start one with `/fork <directive>`.

|                         | Fork                             | Named subagent                              |
| :---------------------- | :------------------------------- | :------------------------------------------ |
| Context                 | Full conversation history        | Fresh context with the task prompt          |
| System prompt and tools | Same as main session             | From the subagent's definition file         |
| Model                   | Same as main session             | From the subagent's `model` field           |
| Prompt cache            | Shared with main session         | Separate cache                              |

When fork mode is enabled, Claude uses forks instead of general-purpose for unspecified Agent tool calls, and all subagent spawns run in the background.

### Disabling specific subagents

Add to `permissions.deny` in settings:
```json
{ "permissions": { "deny": ["Agent(Explore)", "Agent(my-agent)"] } }
```
Or use `--disallowedTools "Agent(Explore)"` on the CLI.

### What a non-fork subagent receives at startup

- Its own system prompt plus environment details (not the full Claude Code system prompt)
- The task/delegation message Claude writes
- CLAUDE.md and memory hierarchy (skipped for Explore and Plan)
- Git status snapshot from session start (skipped for Explore and Plan)
- Full content of any skills listed in its `skills` field

### Key environment variables

| Variable                                    | Effect                                                       |
| :------------------------------------------ | :----------------------------------------------------------- |
| `CLAUDE_CODE_SUBAGENT_MODEL`                | Override model for all subagent invocations                  |
| `CLAUDE_CODE_FORK_SUBAGENT`                 | `1` enables fork mode, `0` disables it everywhere            |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS`      | `1` disables all background task functionality               |
| `CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS=1` | Remove all built-in subagent types in non-interactive/SDK mode |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`           | Trigger subagent auto-compaction at a lower percentage       |

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Complete guide to built-in and custom subagents, configuration, invocation patterns, fork mode, hooks, memory, and example definitions

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
