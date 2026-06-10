---
name: agent-sdk-doc
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the Python and TypeScript library for building production AI agents programmatically.

## Quick Reference

### Installation

| Language | Package | Requirement |
| --- | --- | --- |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

The TypeScript SDK bundles a native Claude Code binary; no separate CLI install needed. Set `ANTHROPIC_API_KEY` to authenticate. Third-party providers: `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1`, or `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`.

### Entry Points

**TypeScript:** `query({ prompt, options? })` — async generator, use `for await`

**Python:** `query(*, prompt, options?, transport?)` — async iterator, use `async for`

**Python multi-turn:** `ClaudeSDKClient` — maintains session automatically across `.query()` calls

### Key `Options` / `ClaudeAgentOptions` Fields

| Field (TS / Python) | Default | Purpose |
| --- | --- | --- |
| `allowedTools` / `allowed_tools` | `[]` | Auto-approve these tools (does not restrict others) |
| `disallowedTools` / `disallowed_tools` | `[]` | Remove tool from context (bare name) or block pattern (scoped: `"Bash(rm *)"`) |
| `permissionMode` / `permission_mode` | `'default'` | See permission modes table below |
| `canUseTool` / `can_use_tool` | — | Callback for runtime approval; pauses execution until resolved |
| `systemPrompt` / `system_prompt` | minimal | String, or `{ type: "preset", preset: "claude_code" }` |
| `mcpServers` / `mcp_servers` | `{}` | MCP server configs (stdio, http, sse, sdk) |
| `hooks` | `{}` | Hook callbacks keyed by `HookEvent` |
| `agents` | — | Programmatic subagent definitions |
| `resume` | — | Session UUID to resume |
| `continue` / `continue_conversation` | `false` | Resume the most recent session in cwd |
| `forkSession` / `fork_session` | `false` | Fork instead of continuing when resuming |
| `maxTurns` / `max_turns` | — | Cap tool-use round trips |
| `maxBudgetUsd` / `max_budget_usd` | — | Stop when client-side cost estimate reaches this USD value |
| `cwd` | process cwd | Working directory for the session |
| `settingSources` / `setting_sources` | all | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `skills` | — | `'all'`, `[]`, or list of skill names to enable |
| `plugins` | `[]` | `[{ type: "local", path: "..." }]` |
| `outputFormat` / `output_format` | — | JSON Schema for structured output |
| `enableFileCheckpointing` / `enable_file_checkpointing` | `false` | Track file changes for `rewindFiles()` |
| `sessionStore` / `session_store` | — | External session storage adapter |
| `persistSession` / `persist_session` | `true` | TS only: disable to skip disk write |
| `effort` | model default | `'low'`\|`'medium'`\|`'high'`\|`'xhigh'`\|`'max'` |
| `model` | CLI default | Model alias or full ID |
| `thinking` | `{ type: 'adaptive' }` | ThinkingConfig |

### Permission Modes

| Mode | Behavior |
| --- | --- |
| `default` | Requires `canUseTool` callback to handle approval |
| `acceptEdits` | Auto-approves file edits and common filesystem commands |
| `bypassPermissions` | Runs every tool without prompting (requires `allowDangerouslySkipPermissions: true`) |
| `dontAsk` | Denies anything not in `allowedTools` |
| `plan` | Read-only exploration; write tools route to `canUseTool` |
| `auto` | Model classifier approves/denies each call (TypeScript only) |

**Evaluation order:** Hooks → Deny rules → Ask rules → Permission mode → Allow rules → `canUseTool`

### Built-in Tools

| Tool | What it does |
| --- | --- |
| `Read` | Read files |
| `Write` | Create/overwrite files |
| `Edit` | Precise edits to existing files |
| `Bash` | Run terminal commands |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web pages |
| `Monitor` | Watch a background script line by line |
| `AskUserQuestion` | Ask clarifying questions (triggers `canUseTool`) |
| `Agent` | Spawn subagents |

### Message Types (stream events)

| Type | When |
| --- | --- |
| `system` / `subtype: "init"` | First message — session metadata, tools, model |
| `assistant` | Claude text or tool calls |
| `user` | Tool results fed back |
| `result` / `subtype: "success"` | Final — includes `result`, `total_cost_usd`, `usage`, `session_id` |
| `result` / `subtype: "error_*"` | Error termination |
| `stream_event` | Raw token stream (when `includePartialMessages: true`) |

### Hook Events

`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `SubagentStart`, `SubagentStop`, `Notification`, `PreCompact`, `PermissionRequest`, `Setup`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `MessageDisplay`

Hook callback signature: `(input, tool_use_id, context) => Promise<HookJSONOutput>`

Hook output fields: `hookSpecificOutput.permissionDecision` (`"allow"` | `"deny"` | `"defer"`), `hookSpecificOutput.permissionDecisionReason`, `outputText` (inject into conversation).

### MCP Server Config Types

| Type | Fields |
| --- | --- |
| stdio (default) | `command`, `args?`, `env?` |
| http | `type: "http"`, `url`, `headers?` |
| sse | `type: "sse"`, `url`, `headers?` |
| sdk (in-process) | `type: "sdk"`, returned by `createSdkMcpServer()` |

MCP tool names in `allowedTools`: `mcp__<server-name>__<tool-name>` (wildcard: `mcp__server__*`)

### Custom Tools (in-process MCP)

**TypeScript:** `tool(name, description, zodSchema, handler, extras?)` → wrap with `createSdkMcpServer({ name, tools })`

**Python:** `@tool(name, description, schema_dict)` decorator → wrap with `create_sdk_mcp_server(name, tools)`

Pass the server to `mcpServers` in `query()`.

### Sessions

- Capture `session_id` from `system/init` message or `ResultMessage`
- **Resume:** `options: { resume: sessionId }` — picks up exact session
- **Continue:** `options: { continue: true }` — resumes most recent session in cwd
- **Fork:** `options: { resume: sessionId, forkSession: true }` — branches from a checkpoint
- **List sessions (TS):** `listSessions({ dir?, limit? })` → `SDKSessionInfo[]`
- **Get messages (TS):** `getSessionMessages(sessionId, { dir?, limit?, offset? })`
- **Rename (TS):** `renameSession(sessionId, title)`
- **Tag (TS):** `tagSession(sessionId, tag | null)`

### Subagents

Define in `agents` option as `Record<string, AgentDefinition>`. Key fields: `description` (required, used by Claude to decide when to delegate), `prompt` (required), `tools?`, `model?`, `background?`, `effort?`, `permissionMode?`. Include `"Agent"` in `allowedTools` to auto-approve subagent invocations.

### Structured Outputs

Set `outputFormat: { type: "json_schema", schema: JSONSchema }` in options. Access via `ResultMessage.structured_output`. Use Zod (TS) or Pydantic (Python) for type safety.

### File Checkpointing

Enable with `enableFileCheckpointing: true`. Call `query.rewindFiles(userMessageId, { dryRun?: boolean })` to restore. Tracks Write, Edit, NotebookEdit — not Bash-mediated changes.

### Observability (OpenTelemetry)

Set env vars (via process env or `options.env`):
- Metrics: `OTEL_METRICS_EXPORTER=otlp` + `OTEL_EXPORTER_OTLP_ENDPOINT`
- Logs: `OTEL_LOGS_EXPORTER=otlp`
- Traces (beta): `OTEL_TRACES_EXPORTER=otlp` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`

In TypeScript, `env` replaces inherited env, so pass `{ ...process.env, YOUR_VAR: "value" }`.

### Cost Tracking

Read `total_cost_usd` from the `ResultMessage` (client-side estimate only — not for billing). Per-step usage on each `AssistantMessage`. Deduplicate by message ID when multiple tool calls share a turn.

### API Timeout Env Vars

| Var | Default | Meaning |
| --- | --- | --- |
| `API_TIMEOUT_MS` | 600000 | Per-request API timeout |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Max retries per request |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | 600000 | Background subagent stall watchdog |
| `CLAUDE_ENABLE_STREAM_WATCHDOG=1` + `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | 300000 | Abort stalled response streams |

### Migration from Claude Code SDK

| Aspect | Old | New |
| --- | --- | --- |
| TS package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Import `query` from | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |

### System Prompt Options

| Starting point | When to use |
| --- | --- |
| No `systemPrompt` | Thin tool-calling loop; you supply all behavior in the user prompt |
| `{ type: "preset", preset: "claude_code" }` | CLI/IDE-like coding tool with a human watching |
| `{ type: "preset", preset: "claude_code", append: "..." }` | Same as above, plus product-specific rules |
| Custom string | Different surface, identity, or permission model |

### `startup()` (TypeScript — pre-warm)

`startup({ options?, initializeTimeoutMs? })` → `WarmQuery`. Spawns subprocess early; call `warm.query(prompt)` later with no startup latency. Implements `AsyncDisposable` for `await using` cleanup.

### `resolveSettings()` (TypeScript — alpha)

Resolves effective settings without spawning the CLI. Returns `{ effective, provenance, sources }`. Accepts `cwd`, `settingSources`, `managedSettings`, `serverManagedSettings`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — What the Agent SDK is, capabilities overview, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes; key concepts, permission modes
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How the agentic loop works, turns, message types, context management
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, `listSessions()`, all types and message types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete API: `query()`, `ClaudeSDKClient`, `@tool`, `ClaudeAgentOptions`, all types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; automatic session management patterns
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — Mirror transcripts to S3/Redis/custom backend via `SessionStore` interface
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Allow/deny rules, permission modes, evaluation order
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback; handling `AskUserQuestion`
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Hook events, matchers, callback signatures, blocking/modifying/logging tool calls
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — Define in-process MCP tools with `tool()` / `@tool` and `createSdkMcpServer`
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Scale to many tools with on-demand discovery
- [MCP](references/claude-code-agent-sdk-mcp.md) — Connect external tools via Model Context Protocol (stdio, http, sse, in-process)
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Programmatic subagent definitions; context isolation, parallelization
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema / Zod / Pydantic typed output from agents
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Real-time token streaming with `includePartialMessages`
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming input mode vs one-shot queries
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Preset, append, custom prompt, output styles, CLAUDE.md
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Using CLAUDE.md, skills, hooks, slash commands from filesystem
- [Skills](references/claude-code-agent-sdk-skills.md) — Using Agent Skills in SDK agents via `skills` option
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Dispatching slash commands through the SDK
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Load local plugins with skills, agents, hooks, MCP servers
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Track and rewind file changes during agent sessions
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage, cost fields, prompt caching, multi-step deduplication
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, and log events
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session persistence, Docker/Kubernetes, multi-tenant isolation
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Permissions, sandboxing, network controls, prompt injection defense
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` and structured Task tools for progress tracking
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Migrate from `@anthropic-ai/claude-code` / `claude-code-sdk`
- [TypeScript V2 Preview (removed)](references/claude-code-agent-sdk-typescript-v2-preview.md) — Reference for the removed V2 session API

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent Loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code Features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Cost Tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Custom Tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File Checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migration Guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying System Prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming Output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 Preview (removed): https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
