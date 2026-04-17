---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK (TypeScript and Python) -- query() API, built-in tools, permission modes, hooks, custom tools, MCP servers, sessions, subagents, streaming, structured outputs, observability, file checkpointing, hosting, secure deployment, cost tracking, and migration guide.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

The Claude Agent SDK lets you embed Claude Code as an agentic coding engine inside your own applications. It wraps the Claude Code CLI as a subprocess, providing a programmatic interface for multi-turn, tool-using conversations. Available in TypeScript (`@anthropic-ai/claude-agent-sdk`) and Python (`claude-agent-sdk`).

### Installation

| Language | Package | Install command |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

Prerequisite: Claude Code CLI must be installed (`npm install -g @anthropic-ai/claude-code`).

### Core API

| Function / Class | Language | Purpose |
| :--- | :--- | :--- |
| `query()` | Both | Main entry point. Returns async iterator/generator of messages |
| `ClaudeSDKClient` | Python | Maintains conversation session across multiple exchanges (continue, interrupt, rewind) |
| `startup()` | TypeScript | Pre-warms CLI subprocess for faster first query |
| `unstable_v2_createSession()` | TypeScript | V2 preview: session-based send/stream pattern |
| `unstable_v2_resumeSession()` | TypeScript | V2 preview: resume a session by ID |
| `unstable_v2_prompt()` | TypeScript | V2 preview: one-shot convenience function |
| `tool()` | Both | Decorator/helper to define custom MCP tools |
| `create_sdk_mcp_server()` / `createSdkMcpServer()` | Both | Create in-process MCP server from `tool()` definitions |
| `list_sessions()` / `listSessions()` | Both | List past sessions with metadata |
| `get_session_messages()` / `getSessionMessages()` | Both | Retrieve messages from a past session |
| `get_session_info()` / `getSessionInfo()` | Both | Read metadata for a single session by ID |
| `rename_session()` / `renameSession()` | Both | Set a custom title on a session |
| `tag_session()` / `tagSession()` | Both | Tag (or clear tag on) a session |

### Built-in tools

| Tool | Description |
| :--- | :--- |
| `Read` | Read file contents |
| `Write` | Create or overwrite files |
| `Edit` | Make targeted edits to existing files |
| `Bash` | Execute shell commands |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `Monitor` | Stream stdout from a background process |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch URL content |
| `AskUserQuestion` | Request input from the user (controlled via `canUseTool` / `can_use_tool`) |
| `ToolSearch` | Discover tools from large MCP servers |
| `Agent` | Spawn a subagent with isolated context |
| `Skill` | Load and invoke a skill |
| `TodoWrite` | Create and track todo items |
| `NotebookEdit` | Edit Jupyter notebook cells |

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Prompt for each tool call not in allow rules |
| `acceptEdits` | Auto-accept file edits; prompt for other tools |
| `plan` | Planning mode -- no execution |
| `dontAsk` | Deny anything not pre-approved instead of prompting |
| `bypassPermissions` | Bypass all permission checks (use with caution) |
| `auto` | TypeScript only -- auto-approve everything without user input |

Permission evaluation order: programmatic hooks --> deny rules --> permission mode --> allow rules --> `canUseTool` callback.

### Message types

| Type | Description |
| :--- | :--- |
| `UserMessage` | User input message |
| `AssistantMessage` | Claude response with content blocks (TextBlock, ThinkingBlock, ToolUseBlock, ToolResultBlock) |
| `SystemMessage` | System metadata (subtypes: `TaskStartedMessage`, `TaskProgressMessage`, `TaskNotificationMessage`) |
| `ResultMessage` | Final result with cost, usage, session ID, and `structured_output` |
| `StreamEvent` | Partial message updates (when `includePartialMessages` / `include_partial_messages` enabled) |
| `RateLimitEvent` | Rate limit status changes (`allowed`, `allowed_warning`, `rejected`) |

### Result subtypes

| Subtype | Meaning |
| :--- | :--- |
| `success` | Completed normally |
| `error_max_turns` | Hit `maxTurns` / `max_turns` limit |
| `error_max_budget_usd` | Hit `maxBudgetUsd` / `max_budget_usd` limit |
| `error_during_execution` | Error or interrupt during execution |
| `error_max_structured_output_retries` | Failed to produce valid structured output |

### Key options (ClaudeAgentOptions / Options)

| Option (Python / TypeScript) | Type | Description |
| :--- | :--- | :--- |
| `prompt` | `str` / `string` | Input prompt (query parameter, not in options) |
| `model` / `model` | `str` / `string` | Claude model to use |
| `fallback_model` / `fallbackModel` | `str` / `string` | Fallback model if primary fails |
| `system_prompt` / `systemPrompt` | `str` or preset | System prompt: string, or `{"type": "preset", "preset": "claude_code", "append": "..."}` |
| `permission_mode` / `permissionMode` | string literal | Permission mode for tool usage |
| `allowed_tools` / `allowedTools` | `list[str]` / `string[]` | Tools to auto-approve (does not restrict available tools) |
| `disallowed_tools` / `disallowedTools` | `list[str]` / `string[]` | Tools to always deny (overrides allow rules and modes) |
| `max_turns` / `maxTurns` | `int` / `number` | Maximum agentic turns |
| `max_budget_usd` / `maxBudgetUsd` | `float` / `number` | Cost limit in USD |
| `mcp_servers` / `mcpServers` | dict/object or path | MCP server configurations |
| `output_format` / `outputFormat` | dict/object | Structured output schema (`{"type": "json_schema", "schema": {...}}`) |
| `can_use_tool` / `canUseTool` | callback | Tool permission callback |
| `hooks` / `hooks` | dict/object | Programmatic hook configurations |
| `agents` / `agents` | dict/object | Subagent definitions |
| `setting_sources` / `settingSources` | list/array | Control filesystem settings loading (`"user"`, `"project"`, `"local"`) |
| `resume` / `resume` | `str` / `string` | Session ID to resume |
| `continue_conversation` / `continueConversation` | `bool` / `boolean` | Continue the most recent conversation |
| `fork_session` / `forkSession` | `bool` / `boolean` | Fork to new session when resuming |
| `include_partial_messages` / `includePartialMessages` | `bool` / `boolean` | Enable streaming events |
| `cwd` / `cwd` | `str` / `string` | Working directory |
| `env` / `env` | dict/object | Environment variables |
| `plugins` / `plugins` | list/array | Load plugins from local paths |
| `sandbox` / `sandbox` | object | Sandbox configuration |
| `thinking` / `thinking` | object | Extended thinking config (`adaptive`, `enabled` with `budget_tokens`, `disabled`) |
| `effort` / `effort` | string literal | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `bool` / `boolean` | Enable file change tracking for rewinding |

### Setting sources

| Value | Location | Description |
| :--- | :--- | :--- |
| `"user"` | `~/.claude/settings.json` | Global user settings |
| `"project"` | `.claude/settings.json` | Shared project settings (version controlled) |
| `"local"` | `.claude/settings.local.json` | Local project settings (gitignored) |

Default: all three. Pass `[]` to disable filesystem settings. Managed policy settings always load regardless.

### Programmatic hook events

| Event | TS | Py | When it fires | Can block? |
| :--- | :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool call executes | Yes |
| `PostToolUse` | Yes | Yes | After a tool call succeeds | No |
| `PostToolUseFailure` | Yes | Yes | After a tool call fails | No |
| `UserPromptSubmit` | Yes | Yes | User submits a prompt | Yes |
| `Stop` | Yes | Yes | Claude finishes responding | Yes |
| `SubagentStart` | Yes | Yes | Subagent spawned | No |
| `SubagentStop` | Yes | Yes | Subagent finishes | Yes |
| `PreCompact` | Yes | Yes | Before context compaction | Yes |
| `PermissionRequest` | Yes | Yes | Permission dialog about to show | Yes |
| `Notification` | Yes | Yes | Claude sends a notification | No |
| `SessionStart` | Yes | No | Session begins or resumes | No |
| `SessionEnd` | Yes | No | Session terminates | No |
| `Setup` | Yes | No | Session setup | No |
| `TeammateIdle` | Yes | No | Agent team teammate about to idle | Yes |
| `TaskCompleted` | Yes | No | Task marked completed | Yes |
| `ConfigChange` | Yes | No | Config file changes during session | Yes |
| `WorktreeCreate` | Yes | No | Worktree being created | Yes |
| `WorktreeRemove` | Yes | No | Worktree being removed | No |

Hooks support matchers (tool name patterns) and return `allow`, `deny`, `ask`, or `defer` decisions in PreToolUse. Async hooks are supported in TypeScript only.

### Custom tools

Define tools with `tool()` and serve them via an in-process MCP server:

```
@tool("name", "description", {"param": str})    # Python
tool("name", "description", {schema}, handler)   # TypeScript
```

Pass to `create_sdk_mcp_server()` / `createSdkMcpServer()`, then add to `mcp_servers` option. Reference tools as `mcp__<serverName>__<toolName>` in `allowed_tools`.

### MCP transport types

| Type | Config key | Description |
| :--- | :--- | :--- |
| stdio | `command`, `args` | Spawn a subprocess (default) |
| SSE | `type: "sse"`, `url` | Server-Sent Events endpoint |
| HTTP | `type: "http"`, `url` | Streamable HTTP endpoint |
| SDK (in-process) | `type: "sdk"` | Created via `createSdkMcpServer()` / `create_sdk_mcp_server()` |

Tool search (`ENABLE_TOOL_SEARCH` env var) enables lazy discovery when server has more than 20 tools (supports up to 10,000 tools, returns 3-5 per search).

### Session management

| Pattern | Option | Description |
| :--- | :--- | :--- |
| New session | (default) | Fresh session with no history |
| Continue | `continueConversation: true` | Continue the most recent session |
| Resume | `resume: "<sessionId>"` | Resume a specific session by ID |
| Fork | `resume` + `forkSession: true` | Branch from a session into a new one |
| ClaudeSDKClient | Python class | Multi-exchange client with interrupt support |
| V2 session | `createSession()` / `resumeSession()` | TypeScript V2 preview interface |

Use `list_sessions()` / `listSessions()` to find sessions. Session IDs appear on every message as `session_id`.

### Subagent configuration (AgentDefinition)

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When to use this agent |
| `prompt` | Yes | The agent's system prompt |
| `tools` | No | Allowed tool names (inherits all if omitted) |
| `model` | No | Model override: `sonnet`, `opus`, `haiku`, `inherit` |
| `skills` | No | Skill names available to this agent |
| `memory` | No | Memory source: `user`, `project`, `local` |
| `mcpServers` | No | MCP servers available to this agent |

Subagents run with isolated context. Define via `agents` option or filesystem (`agents/` directory). Spawned via the `Agent` tool.

### Structured outputs

| Approach | Language | Config |
| :--- | :--- | :--- |
| JSON Schema | Both | `outputFormat: {"type": "json_schema", "schema": {...}}` |
| Zod | TypeScript | `outputFormat: zodToJsonSchema(MySchema)` wrapped |
| Pydantic | Python | Convert model to JSON Schema via `.model_json_schema()` |

Result available in `ResultMessage.structured_output` / `result.structuredOutput`.

### Streaming output

Enable with `includePartialMessages: true` (TS) or `include_partial_messages=True` (Py). Yields `StreamEvent` messages containing raw Claude API stream events (content block deltas for text and tool use).

### Observability (OpenTelemetry)

| Environment variable | Purpose |
| :--- | :--- |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | OTLP collector URL |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers for collector |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol: `http/protobuf` (default), `grpc` |
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Set to `1` to enable |
| `CLAUDE_CODE_TELEMETRY_DISABLE_SENSITIVE` | Set to `1` to omit prompts/responses |
| `CLAUDE_CODE_OTEL_SESSION_TAG` | Custom session tag for filtering |

Exports traces (spans per tool call, turn), metrics (token counts, tool durations), and log events.

### File checkpointing

Enable with `enableFileCheckpointing: true` (TS) or `enable_file_checkpointing=True` (Py). Call `rewindFiles(userMessageId)` on `ClaudeSDKClient` or the TypeScript result object to restore files to their state at a given user message. Checkpoint IDs come from `UserMessage.uuid`.

### Cost tracking

- `ResultMessage.total_cost_usd` / `totalCostUsd` -- client-side estimate for the entire query
- `ResultMessage.model_usage` / `modelUsage` -- per-model breakdown (tokens, cost, web searches)
- `AssistantMessage.usage` / `message_id` -- per-message token usage; deduplicate parallel tool calls by `message_id`

### System prompt customization

| Approach | Description |
| :--- | :--- |
| Custom string | `systemPrompt: "You are..."` -- replaces default |
| Preset | `systemPrompt: {"type": "preset", "preset": "claude_code"}` -- uses Claude Code's system prompt |
| Preset + append | Add `append: "Additional instructions..."` to preset |
| CLAUDE.md | Set `settingSources: ["project"]` to load project instructions |
| `excludeDynamicSections` | Move per-session context to first user message for better prompt caching |

### Hosting patterns

| Pattern | Description |
| :--- | :--- |
| Ephemeral | One container per task, destroyed after |
| Long-running | Persistent server, sessions resume across requests |
| Hybrid | Long-running server spawning ephemeral workers |
| Single container | One container, one agent, sequential tasks |

### Secure deployment

| Concern | Approach |
| :--- | :--- |
| Isolation | `sandbox-runtime`, Docker, gVisor, VMs |
| Credentials | Proxy pattern -- inject via `canUseTool` callback, never in environment |
| Filesystem | `disallowedTools`, deny rules for sensitive paths |
| Network | Restrict outbound via firewall or proxy |

### Migration from claude-code-sdk

The package was renamed from `claude-code-sdk` to `claude-agent-sdk`. Key changes:
- TypeScript: `@anthropic-ai/claude-code-sdk` --> `@anthropic-ai/claude-agent-sdk`; `ClaudeCodeOptions` --> `ClaudeAgentOptions`
- Python: `claude-code-sdk` --> `claude-agent-sdk`; `ClaudeCodeOptions` --> `ClaudeAgentOptions`
- Default system prompt changed from `None`/`undefined` to Claude Code's preset
- Default `settingSources` changed from `[]` to all sources (user + project + local)

## Full Documentation

For the complete official documentation, see the reference files:

- [SDK overview](references/claude-code-agent-sdk-overview.md) -- capabilities, built-in tools, comparison to Client SDK and CLI
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) -- step-by-step setup, bug-fixing example, key concepts
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) -- lifecycle, turns, message types, tool execution, context window, compaction, sessions
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) -- settingSources, CLAUDE.md, skills, hooks, feature comparison
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) -- token usage, total_cost_usd, per-model usage, deduplication
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) -- tool() helper, createSdkMcpServer(), input schemas, error handling, annotations
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) -- checkpointing, rewindFiles(), checkpoint UUIDs
- [Hooks](references/claude-code-agent-sdk-hooks.md) -- programmatic hooks, events, matchers, callback inputs/outputs, async hooks
- [Hosting](references/claude-code-agent-sdk-hosting.md) -- container hosting, deployment patterns, sandbox providers
- [MCP](references/claude-code-agent-sdk-mcp.md) -- MCP server configuration, transport types, tool search, authentication
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) -- package rename, breaking changes
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) -- CLAUDE.md, output styles, systemPrompt, excludeDynamicSections
- [Observability](references/claude-code-agent-sdk-observability.md) -- OpenTelemetry configuration, traces, metrics, logs
- [Permissions](references/claude-code-agent-sdk-permissions.md) -- evaluation order, modes, allow/deny rules, canUseTool
- [Plugins](references/claude-code-agent-sdk-plugins.md) -- loading plugins via SDK, plugin structure, verification
- [Python SDK reference](references/claude-code-agent-sdk-python.md) -- complete Python API: query(), ClaudeSDKClient, tool(), types, message classes
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) -- threat model, isolation, credential management, proxy pattern
- [Sessions](references/claude-code-agent-sdk-sessions.md) -- continue, resume, fork, ClaudeSDKClient, cross-host resume
- [Skills](references/claude-code-agent-sdk-skills.md) -- skills in SDK, filesystem-based, settingSources, Skill tool
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) -- sending slash commands via prompt, /compact
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) -- StreamEvent, partial messages, text/tool streaming
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) -- streaming input (recommended) vs single message input
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) -- JSON Schema, Zod, Pydantic, outputFormat
- [Subagents](references/claude-code-agent-sdk-subagents.md) -- AgentDefinition, context isolation, parallelization, tool restrictions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) -- TodoWrite tool, todo lifecycle, monitoring
- [Tool search](references/claude-code-agent-sdk-tool-search.md) -- ENABLE_TOOL_SEARCH, auto mode, limits
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) -- complete TypeScript API: query(), Options, types, startup()
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) -- V2 session-based send/stream interface
- [User input](references/claude-code-agent-sdk-user-input.md) -- canUseTool callback, AskUserQuestion tool, approval flows

## Sources

- SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
