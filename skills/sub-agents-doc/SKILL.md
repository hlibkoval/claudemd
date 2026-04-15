---
name: sub-agents-doc
description: Complete official Claude Code documentation for subagents — specialized AI assistants with isolated context, custom system prompts, restricted tools, and per-agent permissions used to delegate side tasks, enforce constraints, and preserve main-conversation context.
user-invocable: false
---

# Subagents Documentation

This skill provides the complete official documentation for Claude Code subagents.

## Quick Reference

Subagents are specialized AI assistants that run in their own context window with a custom system prompt, scoped tool access, and independent permissions. The main conversation delegates a task and receives only the subagent's summary. Subagents cannot spawn other subagents; for nested or parallel work across sessions use agent teams.

### Built-in subagents

| Agent             | Model                    | Tools             | Purpose                                           |
| :---------------- | :----------------------- | :---------------- | :------------------------------------------------ |
| Explore           | Haiku                    | Read-only         | Fast file discovery and codebase search           |
| Plan              | Inherits                 | Read-only         | Research during plan mode                         |
| General-purpose   | Inherits                 | All tools         | Multi-step tasks needing exploration plus action  |
| statusline-setup  | Sonnet                   | (helper)          | Invoked when running /statusline                  |
| Claude Code Guide | Haiku                    | (helper)          | Answers questions about Claude Code features     |

### Subagent scope and priority

| Location                     | Scope                   | Priority    |
| :--------------------------- | :---------------------- | :---------- |
| Managed settings             | Organization-wide       | 1 (highest) |
| `--agents` CLI flag          | Current session         | 2           |
| `.claude/agents/`            | Current project         | 3           |
| `~/.claude/agents/`          | All your projects       | 4           |
| Plugin's `agents/` directory | Where plugin is enabled | 5 (lowest)  |

When two definitions share a name, the higher-priority one wins. Plugin subagents do not support the `hooks`, `mcpServers`, or `permissionMode` frontmatter fields.

### Frontmatter fields

| Field             | Required | Description                                                                                                          |
| :---------------- | :------- | :------------------------------------------------------------------------------------------------------------------- |
| `name`            | Yes      | Unique identifier (lowercase letters and hyphens)                                                                    |
| `description`     | Yes      | When Claude should delegate to this subagent                                                                         |
| `tools`           | No       | Allowlist of tools. If omitted, inherits all tools from the parent                                                   |
| `disallowedTools` | No       | Tools to deny — applied before `tools` resolves                                                                      |
| `model`           | No       | `sonnet`, `opus`, `haiku`, a full model ID (e.g. `claude-opus-4-6`), or `inherit` (default)                          |
| `permissionMode`  | No       | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, or `plan`                                          |
| `maxTurns`        | No       | Maximum agentic turns before the subagent stops                                                                      |
| `skills`          | No       | Skill names to inject into the subagent's context at startup (full content, not on-demand)                           |
| `mcpServers`      | No       | MCP servers — by name (reuse parent connection) or inline definition (scoped to the subagent)                        |
| `hooks`           | No       | Lifecycle hooks scoped to this subagent                                                                              |
| `memory`          | No       | Persistent memory scope: `user`, `project`, or `local`                                                               |
| `background`      | No       | `true` to always run as a background task. Default `false`                                                           |
| `effort`          | No       | `low`, `medium`, `high`, or `max` (Opus 4.6 only). Overrides session effort                                          |
| `isolation`       | No       | Set to `worktree` to give the subagent an isolated git worktree copy of the repo                                     |
| `color`           | No       | Display color: `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`                               |
| `initialPrompt`   | No       | First user turn auto-submitted when the agent runs as the main session via `--agent` or the `agent` setting         |

Only `name` and `description` are required. The Markdown body becomes the subagent's system prompt; the subagent does not see Claude Code's default system prompt.

### Tool restrictions

| Field             | Behavior                                                                                                          |
| :---------------- | :---------------------------------------------------------------------------------------------------------------- |
| `tools`           | Allowlist. Only the listed tools are usable                                                                       |
| `disallowedTools` | Denylist. Removes tools from the inherited or specified pool. Applied before `tools` resolves                     |
| `Agent`           | In `tools`, allows spawning any subagent (only meaningful when running as the main thread via `claude --agent`)   |
| `Agent(a, b)`     | Allowlist of spawnable subagent types. Other types fail and are not surfaced                                      |
| Omit `Agent`      | The agent cannot spawn any subagents                                                                              |

If both `tools` and `disallowedTools` are set, `disallowedTools` is applied first; tools listed in both are removed. Use `permissions.deny` with `Agent(name)` in settings.json to disable specific subagents (built-in or custom).

### Permission modes

| Mode                | Behavior                                                                                                              |
| :------------------ | :-------------------------------------------------------------------------------------------------------------------- |
| `default`           | Standard permission checking with prompts                                                                             |
| `acceptEdits`       | Auto-accept file edits and common filesystem commands within the working directory and `additionalDirectories`       |
| `auto`              | Auto mode — a background classifier reviews commands and protected-directory writes                                   |
| `dontAsk`           | Auto-deny permission prompts; explicitly allowed tools still work                                                     |
| `bypassPermissions` | Skip permission prompts (with caveats around `.git`, `.claude`, `.vscode`, `.idea`, `.husky`)                         |
| `plan`              | Plan mode — read-only exploration                                                                                     |

If the parent uses `bypassPermissions`, that takes precedence. If the parent uses `auto`, the subagent inherits auto and any frontmatter `permissionMode` is ignored.

### Persistent memory scopes

| Scope     | Location                                       | Use when                                                                  |
| :-------- | :--------------------------------------------- | :------------------------------------------------------------------------ |
| `user`    | `~/.claude/agent-memory/<agent-name>/`         | The subagent should remember learnings across all projects                |
| `project` | `.claude/agent-memory/<agent-name>/`           | Knowledge is project-specific and shareable via version control (default) |
| `local`   | `.claude/agent-memory-local/<agent-name>/`     | Knowledge is project-specific but should not be checked into VCS          |

When memory is enabled, Read/Write/Edit are auto-enabled, and the first 200 lines or 25KB of `MEMORY.md` is loaded into the system prompt.

### Hook events

Frontmatter hooks (only fire when the agent runs as a subagent via Agent tool or @-mention):

| Event         | Matcher input | When it fires                                                       |
| :------------ | :------------ | :------------------------------------------------------------------ |
| `PreToolUse`  | Tool name     | Before the subagent uses a tool                                     |
| `PostToolUse` | Tool name     | After the subagent uses a tool                                      |
| `Stop`        | (none)        | When the subagent finishes (converted to `SubagentStop` at runtime) |

Project-level hooks in `settings.json` (fire in the main session for subagent lifecycle):

| Event           | Matcher input    | When it fires                    |
| :-------------- | :--------------- | :------------------------------- |
| `SubagentStart` | Agent type name  | When a subagent begins execution |
| `SubagentStop`  | Agent type name  | When a subagent completes        |

### Model resolution order

1. The `CLAUDE_CODE_SUBAGENT_MODEL` environment variable
2. The per-invocation `model` parameter
3. The subagent definition's `model` frontmatter
4. The main conversation's model

### Invoking subagents

- **Natural language**: name the subagent in your prompt; Claude decides whether to delegate.
- **@-mention**: type `@` and pick the subagent (or `@agent-<name>` / `@agent-<plugin>:<agent>`) — guarantees it runs.
- **Session-wide**: `claude --agent <name>` makes the main thread take on the subagent's system prompt, tool restrictions, and model. Set `agent` in `.claude/settings.json` to make it the project default.
- **CLI definition**: `claude --agents '{...}'` defines ephemeral subagents for one session via JSON with the same fields as file-based subagents (use `prompt` for the system prompt body).
- **Listing**: `claude agents` lists all configured subagents grouped by source, marking which are overridden.

### Foreground vs. background

- **Foreground** subagents block the main conversation; permission and clarifying prompts pass through to you.
- **Background** subagents run concurrently. Permissions are pre-approved at launch; afterwards the subagent auto-denies anything not pre-approved, and clarifying questions fail (the subagent continues). Background can be triggered via "run this in the background", Ctrl+B, or `background: true`. Disable entirely with `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`.

### Resuming and transcripts

- Each invocation creates a fresh instance; ask Claude to resume a prior subagent by ID to continue with full prior history.
- Resumption uses the `SendMessage` tool, available only when agent teams are enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`).
- Subagent transcripts live at `~/.claude/projects/{project}/{sessionId}/subagents/agent-{agentId}.jsonl`, persist independently of main-conversation compaction, and are cleaned up via `cleanupPeriodDays` (default 30).
- Subagents support auto-compaction (default ~95%); override with `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Create custom subagents](references/claude-code-sub-agents.md) — Built-in subagents, the `/agents` interface, scope and priority, all frontmatter fields, tool and permission control, MCP scoping, preloaded skills, persistent memory, frontmatter and project-level hooks, invocation patterns (natural language, @-mention, `--agent`), foreground vs. background execution, common patterns (isolation, parallel research, chaining), resumption and transcripts, auto-compaction, and example subagents (code-reviewer, debugger, data-scientist, db-reader).

## Sources

- Create custom subagents: https://code.claude.com/docs/en/sub-agents.md
