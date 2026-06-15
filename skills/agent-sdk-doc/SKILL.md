---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the Python and TypeScript library for building production AI agents programmatically.

## Quick Reference

### Installation

| Language   | Command                                      | Requirement     |
| :--------- | :------------------------------------------- | :-------------- |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+     |
| Python     | `pip install claude-agent-sdk`               | Python 3.10+    |

The TypeScript SDK bundles a native Claude Code binary — no separate CLI install needed. Authentication: set `ANTHROPIC_API_KEY`, or use `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1`, or `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` for cloud providers.

### Core Entry Points

| SDK        | Primary API             | Multi-turn API         |
| :--------- | :---------------------- | :--------------------- |
| TypeScript | `query({ prompt, options })` — async generator | `continue: true` in options |
| Python     | `query(prompt=, options=)` — async iterator | `ClaudeSDKClient` class |

Both yield a stream of typed message objects. Iterate to completion — do not break early.

### Built-in Tools

| Category      | Tools                                              | What they do                                     |
| :------------ | :------------------------------------------------- | :----------------------------------------------- |
| File ops      | `Read`, `Edit`, `Write`                            | Read, modify, create files                       |
| Search        | `Glob`, `Grep`                                     | Find files by pattern, search content with regex |
| Execution     | `Bash`                                             | Run shell commands, scripts, git                 |
| Web           | `WebSearch`, `WebFetch`                            | Search the web, fetch and parse pages            |
| Discovery     | `ToolSearch`                                       | Load deferred tool definitions on demand         |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`  | Spawn subagents, invoke skills, ask the user     |
| Monitoring    | `Monitor`                                          | Watch background script output line by line      |

### Message Types (stream output)

| Type              | Python class        | TS `type` field       | When emitted                                      |
| :---------------- | :------------------ | :-------------------- | :------------------------------------------------ |
| Init              | `SystemMessage`     | `"system"` / `"init"` | Session start; carries session ID, tools, MCP     |
| Assistant turn    | `AssistantMessage`  | `"assistant"`         | Each Claude response (text + tool calls)          |
| Tool results      | `UserMessage`       | `"user"`              | After each tool execution batch                   |
| Streaming chunks  | `StreamEvent`       | `"stream_event"`      | Only when `include_partial_messages=True`         |
| Compact boundary  | `SystemMessage`     | `"system"` / `"compact_boundary"` | After automatic context compaction  |
| Final result      | `ResultMessage`     | `"result"`            | Loop end; carries cost, usage, session ID         |

### Result Subtypes

| Subtype                             | Meaning                                   | `result` field? |
| :---------------------------------- | :---------------------------------------- | :-------------: |
| `success`                           | Task completed normally                   | Yes             |
| `error_max_turns`                   | Hit `maxTurns` limit                      | No              |
| `error_max_budget_usd`              | Hit `maxBudgetUsd` limit                  | No              |
| `error_during_execution`            | API failure or abort                      | No              |
| `error_max_structured_output_retries` | Structured output validation failed     | No              |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Permission Modes

| Mode                | Python value          | Behavior                                                         |
| :------------------ | :-------------------- | :--------------------------------------------------------------- |
| `default`           | `"default"`           | Unmatched tools call your `can_use_tool` / `canUseTool` callback |
| `acceptEdits`       | `"acceptEdits"`       | Auto-approve file edits + filesystem commands (`mkdir`, `mv` …)  |
| `plan`              | `"plan"`              | Read freely, never auto-approve file edits                       |
| `dontAsk`           | `"dontAsk"`           | Deny anything not pre-approved; never prompt                     |
| `bypassPermissions` | `"bypassPermissions"` | Approve all tools without prompting (use in isolated envs only)  |
| `auto`              | TypeScript only       | Model classifier approves/denies each tool call                  |

Permission evaluation order: Hooks → Deny rules → Ask rules → Permission mode → Allow rules → `canUseTool`.

### Effort Levels

| Level    | Best for                                               |
| :------- | :----------------------------------------------------- |
| `"low"`  | File lookups, directory listing                        |
| `"medium"` | Routine edits, standard tasks                        |
| `"high"` | Refactors, debugging                                   |
| `"xhigh"` | Coding and agentic tasks (Fable 5, Opus 4.7+)        |
| `"max"`  | Multi-step problems requiring maximum reasoning depth  |

### Key Options (ClaudeAgentOptions / Options)

| Option (Python / TypeScript)                    | Purpose                                                    |
| :---------------------------------------------- | :--------------------------------------------------------- |
| `allowed_tools` / `allowedTools`                | Auto-approve listed tools (does not block others)          |
| `disallowed_tools` / `disallowedTools`          | Block tools; bare name removes from context, scoped denies |
| `permission_mode` / `permissionMode`            | Global permission behavior                                 |
| `max_turns` / `maxTurns`                        | Cap tool-use round trips                                   |
| `max_budget_usd` / `maxBudgetUsd`               | Cap spend in USD                                           |
| `effort`                                        | Reasoning depth: `"low"` to `"max"`                        |
| `model`                                         | Model alias or full ID                                     |
| `system_prompt` / `systemPrompt`                | Custom or preset (`"claude_code"`) system prompt           |
| `mcp_servers` / `mcpServers`                    | MCP server configurations                                  |
| `agents`                                        | Programmatic subagent definitions                          |
| `hooks`                                         | Lifecycle callback hooks                                   |
| `resume`                                        | Resume a past session by ID                                |
| `continue_conversation` / `continue`            | Resume the most recent session automatically               |
| `fork_session` / `forkSession`                  | Fork a resumed session to a new ID                         |
| `setting_sources` / `settingSources`            | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `plugins`                                       | Load local plugins (`{ type: "local", path: "..." }`)      |
| `output_format` / `outputFormat`                | JSON Schema for structured output validation               |
| `include_partial_messages` / `includePartialMessages` | Enable real-time token streaming                   |
| `enable_file_checkpointing` / `enableFileCheckpointing` | Enable file rewind via `rewindFiles()`           |
| `session_store` / `sessionStore`                | External storage adapter for cross-host session resume     |
| `can_use_tool` / `canUseTool`                   | Runtime permission callback                                |
| `cwd`                                           | Working directory for the agent process                    |
| `sandbox`                                       | Sandbox settings                                           |

### Sessions

| Pattern             | Python                                        | TypeScript                              |
| :------------------ | :-------------------------------------------- | :-------------------------------------- |
| New session         | `query(prompt=...)` (default)                 | `query({ prompt })` (default)           |
| Continue latest     | `ClaudeSDKClient` or `continue_conversation=True` | `continue: true`                    |
| Resume specific     | `options=ClaudeAgentOptions(resume=session_id)` | `options: { resume: sessionId }`      |
| Fork               | `fork_session=True` + `resume=session_id`     | `forkSession: true` + `resume: sessionId` |

Capture `session_id` from `ResultMessage.session_id` (or init `SystemMessage` in TypeScript). Sessions are stored as JSONL under `~/.claude/projects/<encoded-cwd>/`. For cross-host resume, use a `sessionStore` adapter.

Session management functions:
- Python: `list_sessions()`, `get_session_messages()`, `get_session_info()`, `rename_session()`, `tag_session()`
- TypeScript: `listSessions()`, `getSessionMessages()`, `getSessionInfo()`, `renameSession()`, `tagSession()`

### Hooks

Hooks are callback functions registered in the `hooks` option. Each matcher has `matcher` (regex/pipe-list), `hooks` (array of callbacks), and optional `timeout` (seconds, default 60).

| Hook Event          | Python | TypeScript | When it fires                              |
| :------------------ | :----: | :--------: | :----------------------------------------- |
| `PreToolUse`        | Yes    | Yes        | Before a tool executes (can block/modify)  |
| `PostToolUse`       | Yes    | Yes        | After tool returns                         |
| `PostToolUseFailure`| Yes    | Yes        | After tool failure                         |
| `PostToolBatch`     | No     | Yes        | After full batch of tool calls resolves    |
| `UserPromptSubmit`  | Yes    | Yes        | When user prompt is sent                   |
| `Stop`              | Yes    | Yes        | When agent finishes                        |
| `SubagentStart`     | Yes    | Yes        | When a subagent spawns                     |
| `SubagentStop`      | Yes    | Yes        | When a subagent completes                  |
| `PreCompact`        | Yes    | Yes        | Before context compaction                  |
| `PermissionRequest` | Yes    | Yes        | Permission dialog would be displayed       |
| `Notification`      | Yes    | Yes        | Agent status messages                      |
| `SessionStart`      | No     | Yes        | Session initialization                     |
| `SessionEnd`        | No     | Yes        | Session termination                        |
| `MessageDisplay`    | No     | Yes        | Assistant message text completes           |
| `Setup`             | No     | Yes        | Session setup/maintenance                  |
| `TaskCompleted`     | No     | Yes        | Background task completes                  |

Hook callback outputs: return `{}` to allow; use `hookSpecificOutput.permissionDecision` (`"allow"`, `"deny"`, `"ask"`, `"defer"`) for `PreToolUse`; `additionalContext` or `updatedToolOutput` for `PostToolUse`; `systemMessage` to show user text; `async: true` (Python: `async_: true`) for fire-and-forget side effects.

Deny priority: `deny` > `defer` > `ask` > `allow` when multiple hooks apply.

### Subagents

Define subagents in the `agents` option as an `AgentDefinition`:

| Field             | Required | Description                                                          |
| :---------------- | :------: | :------------------------------------------------------------------- |
| `description`     | Yes      | When to use this agent (Claude reads this to decide)                 |
| `prompt`          | Yes      | The subagent's system prompt                                         |
| `tools`           | No       | Tool allowlist; inherits all parent tools if omitted                 |
| `disallowedTools` | No       | Explicit tool blocklist for this agent                               |
| `model`           | No       | Model alias: `"fable"`, `"opus"`, `"sonnet"`, `"haiku"`, `"inherit"` |
| `effort`          | No       | Effort level for this agent                                          |
| `maxTurns`        | No       | Turn cap for this agent                                              |
| `background`      | No       | Run as non-blocking background task                                  |
| `mcpServers`      | No       | MCP server specs for this agent                                      |
| `skills`          | No       | Skill names to preload                                               |
| `permissionMode`  | No       | Permission mode override for this agent                              |

Include `"Agent"` in `allowedTools` to auto-approve subagent invocations. Subagents start with a fresh context — the only channel from parent to subagent is the Agent tool's prompt string.

### MCP Servers

Tool naming convention: `mcp__<server-name>__<tool-name>`. Auto-approve with `allowedTools: ["mcp__github__*"]`.

| Transport | Config key  | When to use                        |
| :-------- | :---------- | :--------------------------------- |
| `stdio`   | `command`, `args`, `env` | Local process (npx, etc.)  |
| `sse`     | `type: "sse"`, `url`, `headers` | SSE remote server   |
| `http`    | `type: "http"`, `url`, `headers` | Streamable HTTP remote |
| `sdk`     | `type: "sdk"`, `instance` | In-process custom tools |

Check MCP connection status from the `system` / `init` message's `mcp_servers` array.

### Custom Tools

Define in-process tools with `@tool` (Python) or `tool()` (TypeScript), bundle with `create_sdk_mcp_server()` / `createSdkMcpServer()`, and pass as an MCP server config. Handlers return `{ content: [{type: "text", text: "..."}] }`. Set `readOnlyHint: true` in `ToolAnnotations` to enable parallel execution.

### Structured Outputs

Pass `output_format={"type": "json_schema", "schema": {...}}` (Python) or `outputFormat: { type: "json_schema", schema: {...} }` (TypeScript). The validated result appears in `ResultMessage.structured_output`. Failed validation returns `error_max_structured_output_retries`.

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true` to receive `StreamEvent` / `SDKPartialAssistantMessage` messages with raw API events. Filter for `content_block_delta` events where `delta.type === "text_delta"` for text chunks.

### Context Window and Compaction

Context accumulates across turns (system prompt, tool definitions, history, tool I/O). Content stable across turns is prompt-cached. When approaching the limit, the SDK automatically compacts (summarizes older history). A `compact_boundary` system message fires when this happens. Use `PreCompact` hook to archive transcripts. Add compaction instructions to `CLAUDE.md`.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` and exporters. Traces also require `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`. Signals: metrics, log events, traces via OTLP. Pass via process env or `options.env`.

### Hosting

The SDK spawns a `claude` CLI subprocess per session. State lives on local disk (`~/.claude/projects/`). For cross-host or serverless: use `sessionStore` adapter to mirror transcripts to external storage. For file changes: use `enableFileCheckpointing` + `rewindFiles()`.

### TypeScript-Only Functions

| Function                  | Purpose                                           |
| :------------------------ | :------------------------------------------------ |
| `startup()`               | Pre-warm CLI subprocess before prompt is ready    |
| `resolveSettings()`       | Inspect merged settings without running an agent  |
| `query().applyFlagSettings()` | Change settings mid-session (streaming mode)  |
| `query().setMcpServers()` | Dynamically replace MCP servers mid-session       |

### Python-Only: `ClaudeSDKClient`

`ClaudeSDKClient` is a context manager that maintains a session across multiple exchanges:

```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("First prompt")
    async for msg in client.receive_response():
        ...
    await client.query("Follow-up prompt")  # same session
    async for msg in client.receive_response():
        ...
```

Supports `interrupt()`, `set_permission_mode()`, `set_model()`, `rewind_files()`, `stop_task()`.

### Migration Note (as of June 15, 2026)

Agent SDK and `claude -p` usage on subscription plans draws from a separate monthly Agent SDK credit, distinct from interactive usage limits.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — What the Agent SDK is, capabilities at a glance, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent from scratch, key concepts for tools and permission modes
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How turns, messages, tool execution, context, and compaction work; handling results
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all types and message types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete API: `query()`, `ClaudeSDKClient`, `@tool`, `create_sdk_mcp_server()`, all types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; cross-host session transfer; session listing/tagging
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission evaluation flow, allow/deny rules, mode details
- [Hooks](references/claude-code-agent-sdk-hooks.md) — All hook events, matcher syntax, callback inputs/outputs, examples
- [Subagents](references/claude-code-agent-sdk-subagents.md) — AgentDefinition fields, context inheritance, invocation, resuming subagents, tool restrictions
- [MCP](references/claude-code-agent-sdk-mcp.md) — Transport types, tool naming, authentication, error handling
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool` decorator, in-process MCP server, tool annotations, error handling
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md, skills, hooks from filesystem
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Preset system prompt, appending instructions, prompt cache optimization
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Real-time token streaming with `includePartialMessages`
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to stream vs collect all at once
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic integration for typed agent results
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Reading `total_cost_usd`, `usage` fields; accuracy caveats
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, log events; OTLP configuration
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` approval callbacks, `AskUserQuestion` tool
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and rewind file changes with `enableFileCheckpointing`
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for external/cross-host session persistence
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool loading to reduce context usage
- [Skills](references/claude-code-agent-sdk-skills.md) — Loading and invoking skills from the SDK
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Sending `/compact` and other commands programmatically
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading local plugins via `SdkPluginConfig`
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns, Docker/Kubernetes deployment
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Network controls, credential management, isolation
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading between SDK versions
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Notes on the removed V2 session API
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate`/`TaskUpdate` tool usage for tracking work
- [Python](references/claude-code-agent-sdk-python.md) — (same as Python SDK Reference above)

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
- TypeScript V2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
