---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: building production AI agents in Python and TypeScript, the agent loop, sessions, permissions, hooks, MCP, subagents, streaming, hosting, and full API references for both languages.

## Quick Reference

### Installation

| Language | Package | Minimum runtime |
|:---------|:--------|:----------------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

TypeScript bundles a native Claude Code binary. Python requires Claude Code installed separately.

### Authentication

| Provider | Environment variables |
|:---------|:----------------------|
| Anthropic | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Built-in Tools

| Tool | What it does |
|:-----|:-------------|
| `Read` | Read files in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script and react to each output line |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options |

### Permission Modes

| Mode | Behavior | Use case |
|:-----|:---------|:---------|
| `default` | Requires `canUseTool` callback for approval | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and common filesystem commands | Trusted development workflows |
| `dontAsk` | Denies anything not in `allowedTools` | Locked-down headless agents |
| `auto` | Model classifier approves or denies each call (TypeScript only) | Autonomous agents with safety guardrails |
| `bypassPermissions` | Runs every tool without prompts | Sandboxed CI, fully trusted environments |
| `plan` | Read-only tools only | Planning/analysis phase |

### Permission Evaluation Order

1. Hooks (can deny or allow outright)
2. Deny rules from `disallowedTools` / `disallowed_tools`
3. Active permission mode
4. Allow rules from `allowedTools` / `allowed_tools`
5. `canUseTool` callback (skipped in `dontAsk` mode)

### Tool Allow/Deny Rules

| Rule form | Effect |
|:----------|:-------|
| `allowedTools: ["Read"]` | `Read` is auto-approved; other tools fall through |
| `disallowedTools: ["Bash"]` | Removes `Bash` from Claude's context entirely |
| `disallowedTools: ["Bash(rm *)"]` | Denies `Bash` calls matching `rm *` even in `bypassPermissions`; other Bash calls proceed normally |

### Session Management

| Approach | When to use |
|:---------|:------------|
| Single `query()` | One-shot task, no follow-up needed |
| `ClaudeSDKClient` (Python) | Multi-turn chat in one process — tracks session automatically |
| `continue: true` / `continue_conversation=True` | Resume the most recent session in the directory after restart |
| `resume: sessionId` | Resume a specific past session by ID |
| `forkSession: true` | Branch off a session to try a different approach |
| `persistSession: false` (TypeScript only) | Ephemeral session, nothing written to disk |

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
|:--------|:----------|:------------------|
| Session | New each call | Reuses same session |
| Streaming input | Yes | Yes |
| Interrupts | No | Yes |
| Multi-turn | Manual via `continue_conversation` / `resume` | Automatic |
| Best for | One-off tasks | Continuous conversations |

### TypeScript Functions

| Function | Description |
|:---------|:------------|
| `query({ prompt, options })` | Main entry point; returns async generator of `SDKMessage` |
| `startup({ options })` | Pre-warms CLI subprocess; returns `WarmQuery` for zero-latency first call |
| `tool(name, desc, schema, handler)` | Creates type-safe MCP tool definition |
| `createSdkMcpServer({ name, tools })` | Creates in-process MCP server |
| `listSessions({ dir, limit })` | Lists past sessions with metadata |
| `getSessionMessages(sessionId, opts)` | Reads messages from a past session transcript |
| `getSessionInfo(sessionId, opts)` | Reads metadata for a single session |
| `renameSession(sessionId, title)` | Renames a session |
| `tagSession(sessionId, tag)` | Tags a session (`null` clears the tag) |
| `resolveSettings(opts)` | Resolves effective settings without spawning the CLI |

### Python Functions / Classes

| Function / Class | Description |
|:----------------|:------------|
| `query(*, prompt, options)` | Main entry point; async iterator of `Message` |
| `ClaudeSDKClient` | Persistent session client for multi-turn conversations |
| `tool(name, desc, schema)` | Decorator for MCP tool definitions |
| `create_sdk_mcp_server(name, tools)` | Creates in-process MCP server |
| `list_sessions(directory, limit)` | Lists past sessions (synchronous) |
| `get_session_messages(session_id, ...)` | Reads messages from a session (synchronous) |
| `get_session_info(session_id, ...)` | Reads metadata for a single session (synchronous) |
| `rename_session(session_id, title)` | Renames a session (synchronous) |
| `tag_session(session_id, tag)` | Tags a session (synchronous) |

### Key TypeScript `Options` Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `prompt` | required | Task string or async iterable of `SDKUserMessage` |
| `allowedTools` | `[]` | Auto-approve these tools |
| `disallowedTools` | `[]` | Block / remove these tools |
| `permissionMode` | `'default'` | Permission mode |
| `maxTurns` | `undefined` | Max agentic turns |
| `maxBudgetUsd` | `undefined` | Stop when cost estimate reaches this USD value |
| `resume` | `undefined` | Session ID to resume |
| `continue` | `false` | Resume most recent session |
| `forkSession` | `false` | Fork when resuming |
| `systemPrompt` | `undefined` | String or `{ type: 'preset', preset: 'claude_code' }` |
| `mcpServers` | `{}` | MCP server configs |
| `agents` | `undefined` | Programmatically-defined subagents |
| `hooks` | `{}` | Hook callbacks |
| `settingSources` | all | Which filesystem settings layers to load |
| `cwd` | `process.cwd()` | Working directory |
| `model` | CLI default | Claude model to use |
| `effort` | `'high'` | `'low'` / `'medium'` / `'high'` / `'xhigh'` / `'max'` |
| `thinking` | adaptive | `ThinkingConfig` controlling reasoning behavior |
| `outputFormat` | `undefined` | `{ type: 'json_schema', schema }` for structured outputs |
| `enableFileCheckpointing` | `false` | Enable file rewind support |
| `sessionStore` | `undefined` | External session storage adapter |
| `plugins` | `[]` | Local plugin configs |
| `skills` | `undefined` | Skill names or `'all'` to enable |
| `sandbox` | `undefined` | Sandbox settings |
| `persistSession` | `true` | Write session to disk |

### Python `ClaudeAgentOptions` Key Fields

| Field | Default | Description |
|:------|:--------|:------------|
| `allowed_tools` | `[]` | Auto-approve these tools |
| `disallowed_tools` | `[]` | Block / remove these tools |
| `permission_mode` | `None` | Permission mode |
| `max_turns` | `None` | Max agentic turns |
| `max_budget_usd` | `None` | Stop when cost reaches this USD value |
| `resume` | `None` | Session ID to resume |
| `continue_conversation` | `False` | Resume most recent session |
| `fork_session` | `False` | Fork when resuming |
| `system_prompt` | `None` | String or preset dict |
| `mcp_servers` | `{}` | MCP server configs |
| `agents` | `None` | Programmatically-defined subagents |
| `hooks` | `None` | Hook configurations |
| `setting_sources` | `None` (all) | Which filesystem settings layers to load |
| `cwd` | `None` | Working directory |
| `model` | `None` | Claude model to use |
| `effort` | `None` | `EffortLevel` |
| `thinking` | `None` | `ThinkingConfig` |
| `output_format` | `None` | `{ "type": "json_schema", "schema": {...} }` |
| `enable_file_checkpointing` | `False` | Enable file rewind support |
| `session_store` | `None` | External session storage adapter |
| `plugins` | `[]` | Local plugin configs |
| `skills` | `None` | Skill names or `"all"` |

### Message Types (SDKMessage union)

| Type | Subtype / Key field | Description |
|:-----|:-------------------|:------------|
| `assistant` | — | Claude's response; `message.content` = content blocks |
| `user` | — | User input message |
| `result` | `success` | Final result with `result` string, `total_cost_usd`, `usage` |
| `result` | `error_max_turns` / `error_during_execution` / `error_max_budget_usd` | Error result |
| `system` | `init` | Session init: tools, model, permissions, skills |
| `system` | `compact_boundary` | Context compaction boundary |
| `system` | `permission_denied` | Auto-denied tool call (v2.1.136+) |
| `system` | `plugin_install` | Plugin installation progress |

`SDKResultMessage` notable fields: `total_cost_usd`, `usage`, `num_turns`, `duration_ms`, `terminal_reason`, `permission_denials`, `structured_output`, `deferred_tool_use`.

### Hook Events (SDK Callbacks)

| Event | Fires when |
|:------|:-----------|
| `PreToolUse` | Before a tool call executes |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After a full parallel tool batch resolves |
| `UserPromptSubmit` | User submits a prompt |
| `SessionStart` | Session begins |
| `SessionEnd` | Session terminates |
| `Stop` | Claude finishes responding |
| `SubagentStart` | Subagent spawns |
| `SubagentStop` | Subagent finishes |
| `PreCompact` | Before context compaction |
| `PermissionRequest` | Permission dialog about to appear |
| `TeammateIdle` | Agent team member about to go idle |
| `TaskCompleted` | Task marked completed |
| `ConfigChange` | Config file changes during session |
| `WorktreeCreate` | Worktree being created |
| `WorktreeRemove` | Worktree being removed |
| `MessageDisplay` | Assistant message text streams to screen |
| `Setup` | `--init-only` / maintenance mode |
| `Notification` | Claude Code sends a notification |

Hook callback signature: `(input, toolUseId, { signal }) => Promise<HookJSONOutput>`. `HookCallbackMatcher` has optional `matcher` (pipe-separated tool names or regex), `hooks` array, and `timeout`.

### `AgentDefinition` Fields

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When to use this agent (natural language) |
| `prompt` | Yes | System prompt for the agent |
| `tools` | No | Allowed tool names; inherits parent tools if omitted |
| `disallowedTools` | No | Tools explicitly denied for this agent |
| `model` | No | Model override (`'sonnet'`, `'opus'`, `'haiku'`, `'inherit'`, or full ID) |
| `skills` | No | Skill names to preload |
| `maxTurns` | No | Maximum agentic turns |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Reasoning effort level or integer |
| `permissionMode` | No | Permission mode for this agent's tool execution |

Note: `AgentDefinition` in Python uses camelCase field names (`disallowedTools`, `permissionMode`, `maxTurns`), not snake_case.

### MCP Server Config Types

| Type | Required fields | Optional fields |
|:-----|:----------------|:----------------|
| `stdio` (default) | `command` | `args`, `env` |
| `sse` | `type: 'sse'`, `url` | `headers` |
| `http` | `type: 'http'`, `url` | `headers` |
| `sdk` | `type: 'sdk'`, `name`, `instance` | — |

### Setting Sources

| Value | Location | Use |
|:------|:---------|:----|
| `'user'` | `~/.claude/settings.json` | Personal global settings |
| `'project'` | `.claude/settings.json` | Shared project settings |
| `'local'` | `.claude/settings.local.json` | Local gitignored settings |

Pass `[]` to disable all filesystem settings. Managed policy settings load regardless.

### `ThinkingConfig` Variants

| Variant | Key fields | Description |
|:--------|:-----------|:------------|
| `{ type: 'adaptive' }` | optional `display` | Claude decides when to think (default for supported models) |
| `{ type: 'enabled', budget_tokens: N }` | `budget_tokens`, optional `display` | Fixed token budget for thinking |
| `{ type: 'disabled' }` | — | Disable thinking |

`display`: `'summarized'` or `'omitted'`. On Opus 4.7+, default is `'omitted'`; set `'summarized'` to receive thinking content.

### File Checkpointing

Enable with `enableFileCheckpointing: true` / `enable_file_checkpointing=True`. Call `query.rewindFiles(userMessageId)` (TypeScript) or `client.rewind_files(user_message_id)` (Python) to restore files to their state at a given message. Pass `{ dryRun: true }` (TypeScript) to preview changes.

### Cost Tracking

`SDKResultMessage.total_cost_usd` — client-side estimate (input + output + cache tokens). Use `maxBudgetUsd` / `max_budget_usd` to cap spending; session ends with `error_max_budget_usd` when limit reached. For cross-session tracking, sum `total_cost_usd` across all result messages. Actual billed amounts may differ; see Anthropic Console for authoritative figures.

### Structured Outputs

Pass `outputFormat: { type: 'json_schema', schema: {...} }` / `output_format`. On success, `SDKResultMessage.structured_output` holds the validated JSON. On validation failure after retries, subtype is `error_max_structured_output_retries`. In Python, pass as a plain dict.

### Streaming vs. Single-turn Mode

**Streaming Input Mode** (recommended): persistent process, supports interrupts, multi-turn, image uploads, queued messages, full tool access. Use `AsyncIterable<SDKUserMessage>` as prompt in TypeScript or `ClaudeSDKClient` in Python.

**Single-turn**: one-shot queries. Simpler but no interrupts and requires manual session tracking for follow-ups.

### Hosting Patterns

| Pattern | Description | Best for |
|:--------|:------------|:---------|
| Ephemeral sessions | One container per task, destroyed on completion | One-off tasks (bug fix, doc generation) |
| Long-running sessions | Persistent containers, multiple sessions per container | Email agents, chat bots, continuous pipelines |
| Hybrid | Long-lived containers with per-task working directories | Mix of both |

Each agent session = one `claude` subprocess. Pass `cwd` per-session for isolation. Session transcripts live in `~/.claude/projects/` by default. Use `SessionStore` adapter for cross-host persistence.

### Subprocess Timeout Variables (via `env` option)

| Variable | Default | Description |
|:---------|:--------|:------------|
| `API_TIMEOUT_MS` | 600000 | Per-request timeout in ms |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Maximum API retries |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | 600000 | Stall watchdog for background subagents |
| `CLAUDE_ENABLE_STREAM_WATCHDOG` | off | Abort stalled response streams when set to `1` |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | 300000 | Idle threshold for stream watchdog |

### `Query` Object Methods (TypeScript)

| Method | Description |
|:-------|:------------|
| `interrupt()` | Interrupt the query (streaming input mode only) |
| `rewindFiles(msgId, opts?)` | Restore files to state at given message |
| `setPermissionMode(mode)` | Change permission mode mid-session |
| `setModel(model?)` | Change model mid-session |
| `applyFlagSettings(settings)` | Merge settings into flag layer at runtime |
| `streamInput(stream)` | Stream additional input messages |
| `stopTask(taskId)` | Stop a running background task |
| `mcpServerStatus()` | Get MCP server connection status |
| `setMcpServers(servers)` | Replace MCP server set dynamically |
| `close()` | Terminate the underlying process |

### `startup()` (TypeScript)

Pre-warms the CLI subprocess before a prompt is ready. Returns a `WarmQuery` — call `.query(prompt)` on it to send the prompt to the already-started process with no startup latency.

### Session Storage (`SessionStore` interface)

Implement `load(sessionId)` and `save(sessionId, data)` to mirror session transcripts to an external backend (Redis, S3, etc.) so sessions can be resumed on any host. Pass as `sessionStore` / `session_store` in options. Use `sessionStoreFlush: 'eager'` for more frequent writes; `'batched'` (default) flushes once per turn.

### Migration from `-p` / `claude_code_sdk`

The Agent SDK replaces the legacy `claude -p` approach and the old `claude_code_sdk` Python package. Key changes: `claude_code_sdk` → `claude_agent_sdk`, `ClaudeCodeOptions` → `ClaudeAgentOptions`, `cli_path` → use bundled binary, hooks are callback functions not shell commands. See the migration guide reference for full details.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK Overview](references/claude-code-agent-sdk-overview.md) — What the SDK is, capabilities, comparison with Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes; permission modes, tool combinations
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How the agentic loop works internally
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Using skills, commands, memory, plugins via `settingSources`
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all Options fields, message types, hook types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete API: `query()`, `ClaudeSDKClient`, `@tool` decorator, `ClaudeAgentOptions`, all types
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, evaluation order
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Hook callback patterns, blocking, logging, transforming inputs
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; automatic session management; cross-host persistence
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for external backends
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Defining and spawning specialized subagents
- [MCP Integration](references/claude-code-agent-sdk-mcp.md) — Connecting MCP servers; in-process SDK MCP servers; custom tools
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — Creating and registering custom tools with `tool()` / `@tool`
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion`, interactive approval flows
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Processing the message stream
- [Streaming vs. Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use streaming input mode vs one-shot queries
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema output validation
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Reading `total_cost_usd`, budget caps, per-model usage
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshotting and rewinding file changes
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — Monitoring agent task progress
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Deferred tool schema loading
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom prompts, presets, prompt caching
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading plugins programmatically in SDK sessions
- [Skills](references/claude-code-agent-sdk-skills.md) — Using skills via the `skills` option
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Using slash commands in SDK sessions
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, tracing, monitoring agent runs
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Docker, Kubernetes, subprocess model, session patterns for production
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Network controls, credential management, isolation
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Migrating from `claude_code_sdk` / `claude -p`
- [TypeScript v2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Upcoming TypeScript SDK v2 changes

## Sources

- Agent SDK Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent Loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code Features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Cost Tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Custom Tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File Checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- MCP Integration: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migration Guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying System Prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming Output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs. Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript v2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
