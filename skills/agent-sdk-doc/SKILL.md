---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the programmatic interface for embedding Claude Code agents in TypeScript and Python applications. It covers installation, the agent loop, permissions, sessions, custom tools, MCP servers, subagents, streaming, structured outputs, hooks, observability, hosting, and both language API references.

## Quick Reference

### Packages

| Language | Package | Import |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `import { query } from "@anthropic-ai/claude-agent-sdk"` |
| Python | `claude-agent-sdk` (`pip install claude-agent-sdk`) | `from claude_agent_sdk import query, ClaudeAgentOptions` |

Old package names (`@anthropic-ai/claude-code`, `claude-code-sdk`, `claude_code_sdk`) and `ClaudeCodeOptions` were renamed; see the migration guide.

### Core Entry Point: `query()`

```typescript
// TypeScript
for await (const message of query({ prompt, options })) { ... }
```
```python
# Python
async for message in query(prompt=prompt, options=ClaudeAgentOptions(...)): ...
```

Python also provides `ClaudeSDKClient` for multi-turn conversations without manually passing session IDs.

### Message Types

| Type | Subtype | Description |
| :--- | :--- | :--- |
| `system` | `init` | Session init; contains `session_id`, `slash_commands`, `tools` |
| `system` | `compact_boundary` | Context was compacted |
| `assistant` | — | Claude's response; contains `message.content` blocks |
| `user` | — | Echoed user turns |
| `result` | `success` | Final result; contains `result` (string), `session_id`, `total_cost_usd`, `structured_output` |
| `result` | `error_max_turns` | Stopped at `maxTurns` limit |
| `result` | `error_max_budget_usd` | Stopped at cost limit |
| `result` | `error_max_structured_output_retries` | Could not produce valid structured output |
| `stream_event` (TS) / `StreamEvent` (Py) | — | Raw API streaming event (only with `includePartialMessages`) |

### Key `Options` / `ClaudeAgentOptions` Fields

| Option (TS / Python) | Default | Description |
| :--- | :--- | :--- |
| `maxTurns` / `max_turns` | unlimited | Max tool-use round trips |
| `maxBudgetUsd` / `max_budget_usd` | — | Stop when client-side cost estimate exceeds this USD value |
| `permissionMode` / `permission_mode` | `"default"` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan`, `auto` (TS only) |
| `allowedTools` / `allowed_tools` | `[]` | Tools to auto-approve (does not restrict; use `disallowedTools` to block) |
| `disallowedTools` / `disallowed_tools` | `[]` | Bare name removes tool; scoped rule (e.g. `"Bash(rm *)"`) denies matching calls in all modes |
| `tools` / `tools` | — | Array of tool names or `{ type: 'preset', preset: 'claude_code' }` |
| `systemPrompt` / `system_prompt` | minimal | String, or `{ type: 'preset', preset: 'claude_code', append?, excludeDynamicSections? }` |
| `cwd` | `process.cwd()` | Working directory |
| `model` | CLI default | Model alias or full ID |
| `effort` | model default | `low`, `medium`, `high`, `xhigh`, `max` |
| `mcpServers` / `mcp_servers` | `{}` | MCP server configs |
| `hooks` | `{}` | Programmatic hook callbacks |
| `agents` | — | Programmatic subagent definitions (`Record<string, AgentDefinition>`) |
| `skills` / `skills` | — | `"all"`, list of names, or `[]` to disable all |
| `settingSources` / `setting_sources` | all | Which filesystem sources to load: `"user"`, `"project"`, `"local"` |
| `outputFormat` / `output_format` | — | `{ type: 'json_schema', schema }` for structured outputs |
| `includePartialMessages` / `include_partial_messages` | `false` | Emit raw streaming events |
| `continue` / `continue_conversation` | `false` | Resume most recent session in `cwd` |
| `resume` | — | Resume specific session by ID |
| `forkSession` / `fork_session` | `false` | Fork instead of continuing when used with `resume` |
| `sessionStore` / `session_store` | — | External session store adapter |
| `enableFileCheckpointing` / `enable_file_checkpointing` | `false` | Track file changes for rewind |
| `canUseTool` / `can_use_tool` | — | Callback for tool permission prompts and `AskUserQuestion` |
| `env` | `process.env` | Subprocess environment (replaces, not merges) |
| `persistSession` | `true` (TS only) | `false` = in-memory only, no resume |

### Permission Modes

| Mode | Auto-approves | Notes |
| :--- | :--- | :--- |
| `default` | Nothing | Hooks/allow rules still fire; unmatched → prompt |
| `acceptEdits` | File edits + filesystem Bash | Does not approve network Bash |
| `dontAsk` | Nothing; unmatched → deny | No user prompt |
| `bypassPermissions` | Everything | Requires `allowDangerouslySkipPermissions: true`; hooks/deny/ask still evaluated |
| `plan` | Never auto-approves writes | Ask/allow rules apply during exploration; writes always require approval |
| `auto` | Model classifier decides | TypeScript only |

### Permission Evaluation Order

Hooks → deny rules → ask rules → permission mode → allow rules → `canUseTool`

### Built-in Tools

| Tool | Category | Notes |
| :--- | :--- | :--- |
| `Read`, `Write`, `Edit`, `NotebookEdit` | File | `Write`/`Edit`/`NotebookEdit` tracked by file checkpointing |
| `Bash` | Shell | Commands parsed into AST for permission matching |
| `Glob`, `Grep` | Search | Read-only; run in parallel |
| `WebSearch`, `WebFetch` | Web | — |
| `Agent` | Orchestration | Spawns subagents; must be in `allowedTools` |
| `Workflow` | Orchestration | Large-scale parallel orchestration (TS v0.3.149+) |
| `Skill` | Skills | Added automatically when `skills` option is set |
| `AskUserQuestion` | User input | Multiple-choice clarifying questions; 1–4 questions, 2–4 options each |
| `TodoWrite` / `TaskCreate` / `TaskUpdate` | Tasks | `TaskCreate`/`TaskUpdate` default since v2.1.142; `TodoWrite` via `CLAUDE_CODE_ENABLE_TASKS=0` |

### MCP Servers

```typescript
// TypeScript — stdio
mcpServers: { myserver: { command: "npx", args: ["-y", "my-mcp-server"] } }
// TypeScript — HTTP/SSE
mcpServers: { myserver: { type: "http", url: "https://tools.example.com/mcp" } }
// Wildcard allow
allowedTools: ["mcp__myserver__*"]
```
Tool naming: `mcp__<server>__<tool>`. Auth: `env` field (stdio) or `headers` (HTTP). In-process: use `createSdkMcpServer()`.

### Custom Tools

```typescript
// TypeScript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";
const greet = tool("greet", "Greet a user", { name: z.string() },
  async ({ name }) => ({ content: [{ type: "text", text: `Hello ${name}` }] }));
const server = createSdkMcpServer({ name: "my-tools", tools: [greet] });
// Python
from claude_agent_sdk import tool, create_sdk_mcp_server
@tool("greet", "Greet a user", {"name": str})
async def greet(args): return {"content": [{"type": "text", "text": f"Hello {args['name']}"}]}
server = create_sdk_mcp_server(name="my-tools", tools=[greet])
```

Set `annotations: { readOnlyHint: true }` to allow parallel execution. Return `{ isError: true, content: [...] }` for graceful tool errors.

### Tool Search

Enabled by default (disabled on Vertex AI and non-first-party `ANTHROPIC_BASE_URL`). Defers tool definitions from context; agent discovers on demand. Control via `ENABLE_TOOL_SEARCH` env var: unset (on), `"true"` (force on), `"false"` (off), `"auto"` (threshold 10% of context), `"auto:N"` (custom %). Supports up to 10,000 tools; returns 3–5 per search. Not supported on Haiku.

### Sessions

| Need | How |
| :--- | :--- |
| Single prompt | Plain `query()` |
| Multi-turn in one process | `ClaudeSDKClient` (Python) or `continue: true` (TS) |
| Resume most recent after restart | `continue_conversation=True` / `continue: true` |
| Resume specific past session | Capture `ResultMessage.session_id`, pass to `resume` |
| Branch without losing original | `forkSession: true` / `fork_session=True` with `resume` |
| No disk persistence (TS only) | `persistSession: false` |

Session files: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. Functions: `listSessions()`, `getSessionMessages()`, `getSessionInfo()`, `renameSession()`, `tagSession()`.

### Session Storage (External)

```typescript
import { InMemorySessionStore } from "@anthropic-ai/claude-agent-sdk";
const store = new InMemorySessionStore(); // dev/test
// Use with: options: { sessionStore: store }
// Resume: options: { sessionStore: store, resume: sessionId }
```

Implement `SessionStore` with `append(key, entries)` and `load(key)` against S3, Redis, Postgres, etc. Reference adapters in `examples/session-stores/` of the TS repo. Mirror writes are best-effort; monitor for `mirror_error` events. Cannot combine with `persistSession: false` or `enableFileCheckpointing`.

### File Checkpointing

```typescript
// Enable
options: { enableFileCheckpointing: true, extraArgs: { "replay-user-messages": null } }
// Rewind
const checkpoint = message.uuid; // from any AssistantMessage or ResultMessage
await queryObject.rewindFiles(checkpoint);
// Python
await rewind_files(checkpoint_id=checkpoint)
```

Tracks changes to `Write`, `Edit`, `NotebookEdit` only (not `Bash`). `extraArgs: {"replay-user-messages": null}` required so messages get UUIDs for use as checkpoint IDs.

### Structured Outputs

```typescript
options: { outputFormat: { type: "json_schema", schema: mySchema } }
// Access result
if (message.type === "result" && message.subtype === "success" && message.structured_output) { ... }
```

Use Zod `z.toJSONSchema(MySchema)` (TS) or `MyModel.model_json_schema()` (Python/Pydantic) to generate schema. Error subtype `error_max_structured_output_retries` on failure.

### Streaming Output

```typescript
options: { includePartialMessages: true }
// Check for: message.type === "stream_event"
// Text: event.type === "content_block_delta" && event.delta.type === "text_delta"
// Tool input: event.type === "content_block_delta" && event.delta.type === "input_json_delta"
```

Python: check `isinstance(message, StreamEvent)`, then `event.get("type") == "content_block_delta"`.

### Input Modes

| Mode | How | Supports images? | Supports interruption? |
| :--- | :--- | :--- | :--- |
| Single message (default) | `prompt: "string"` | No | No |
| Streaming input | `prompt: AsyncGenerator<SDKUserMessage>` | Yes | Yes |

Python streaming input requires `ClaudeSDKClient`. Note: generator exceptions in TS produce `"Claude Code process aborted by user"` error; in Python the session stalls silently — enable debug logging if stuck.

### Subagents

Add `"Agent"` to `allowedTools`. Define programmatically:

```typescript
options: {
  allowedTools: ["Agent", "Read", "Grep"],
  agents: {
    "specialist": {
      description: "Does X",
      prompt: "You are a specialist...",
      tools: ["Read", "Grep"],
      model: "sonnet",  // alias or full ID
      background: false,
      effort: "high",
    }
  }
}
```

Subagents inherit: `cwd`, `env`, `settingSources`, `permissionMode`. They do NOT inherit: `maxTurns`, `hooks`, `systemPrompt`, `agents`. Resume a subagent by passing `agentId` in `extra_args` of the tool result. Use `Workflow` tool (TS v0.3.149+) for large-scale parallel orchestration.

### Hooks (Programmatic)

```typescript
// TypeScript
hooks: {
  PreToolUse: [{ matcher: "Bash", hooks: [async (input, toolUseId, ctx) => {
    return { hookSpecificOutput: { permissionDecision: "allow" } };
  }]}]
}
// Python
hooks={"PreToolUse": [HookMatcher(matcher="Bash", hooks=[my_async_fn])]}
```

Hook callback receives `(input_data, tool_use_id, context)`. Return `{ continue_: True }` (Python) or `{}` (TS) to pass through. Key decisions: `permissionDecision: "allow"|"deny"|"ask"|"defer"`. Set `async_: True` / `async: true` for non-blocking hooks. 20 hook events total; see hooks reference for full event list.

### Claude Code Features via SDK

Control which filesystem settings load with `settingSources` (`"user"`, `"project"`, `"local"`). `settingSources` does NOT control: `systemPrompt`, `mcpServers`, `permissionMode`, `allowedTools`, or any `query()` option. CLAUDE.md loads from `cwd`, all parent dirs, and user home (`~/.claude/CLAUDE.md`).

### System Prompts

Three starting points:
- Default (minimal): omit `systemPrompt` — no tool definitions or Claude Code identity
- Claude Code preset: `systemPrompt: { type: "preset", preset: "claude_code" }`
- Custom string: `systemPrompt: "You are..."`

Add `append: "extra instructions"` to extend the preset. Set `excludeDynamicSections: true` to move per-session context to the first user message for better prompt-cache reuse across machines.

### Cost Tracking

```typescript
// On ResultMessage:
message.total_cost_usd   // client-side estimate (float)
message.model_usage      // per-model breakdown: { "claude-X": { input_tokens, output_tokens, cache_read_input_tokens, cache_creation_input_tokens } }
```

Python: `message.total_cost_usd`, `message.model_usage`. Set `ENABLE_PROMPT_CACHING_1H=1` for 1-hour prompt cache TTL.

### Observability (OpenTelemetry)

```bash
CLAUDE_CODE_ENABLE_TELEMETRY=1
CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1   # distributed traces
OTEL_TRACES_EXPORTER=otlp
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=my-agent
```

Span names: `claude_code.interaction`, `claude_code.llm_request`, `claude_code.tool`, `claude_code.hook`. W3C trace context propagated automatically.

### User Input and Approvals

Pass `canUseTool` / `can_use_tool` callback to handle tool approvals and `AskUserQuestion` clarifying questions:

```typescript
canUseTool: async (toolName, input, { suggestions }) => {
  if (toolName === "AskUserQuestion") { /* display questions, return answers */ }
  const ok = await promptUser(toolName, input);
  return ok ? { behavior: "allow", updatedInput: input }
             : { behavior: "deny", message: "User declined" };
}
```

Python requires streaming input mode plus a `PreToolUse` hook returning `{"continue_": True}` to keep the stream open.

### Todo / Task Tracking

Monitor `TaskCreate` and `TaskUpdate` tool_use blocks in the assistant stream. `TaskCreate` adds items (`subject`, `description`); `TaskUpdate` patches by `taskId` with `status` (`pending`/`in_progress`/`completed`/`deleted`). The assigned `taskId` comes back in the tool result, not the tool input. Read `taskId`/`id`/`task_id` defensively (Claude may emit non-canonical key names in the stream).

### Slash Commands

Send as prompt string: `prompt: "/compact"`. Discover available commands from `SystemMessage` init: `message.slash_commands`. Built-in: `/compact`, `/clear` (requires v2.1.117+). Custom commands: `.claude/commands/<name>.md` (legacy) or `.claude/skills/<name>/SKILL.md` (preferred). Support frontmatter `allowed-tools`, `description`, `model`, `argument-hint`; body supports `!`backtick bash execution and `@file` file inclusion.

### Plugins

```typescript
options: { plugins: [{ type: "local", path: "./my-plugin" }] }
```

Plugin skills invoked as `/plugin-name:skill-name`. Plugin structure: `.claude-plugin/plugin.json` (optional) with `name`, `version`, `skills`, `hooks`, `mcpServers`. Auto-discovered if manifest is absent.

### Hosting Patterns

| Pattern | Description |
| :--- | :--- |
| Ephemeral | New session per task, discard after; simple, no state management |
| Long-running | One persistent session; use `ClaudeSDKClient` or `continue` |
| Hybrid | Ephemeral tasks that can resume via session ID on interruption |
| Multi-agent | Orchestrator spawns specialized subagents via `Agent` tool |

Container baseline: 1 GiB RAM, 5 GiB disk, 1 CPU. For multi-tenant isolation: `settingSources: []`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, per-tenant `CLAUDE_CONFIG_DIR` and `cwd`.

### Secure Deployment

Threat: prompt injection from processed content. Mitigations: permissions system (allow/deny rules), command AST parsing, web search summarization, sandbox mode. Isolation options: sandbox-runtime (lightweight), containers with `--cap-drop ALL --network none` + Unix socket proxy, gVisor (kernel-level isolation), Firecracker microVMs. Credential pattern: run proxy outside agent boundary; agent calls proxy which injects credentials. Filesystem: mount code read-only; exclude `.env`, `~/.aws/credentials`, `~/.ssh`, etc. Use `tmpfs` for ephemeral writes.

### Migration from Old SDK

| Old | New |
| :--- | :--- |
| `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| `claude-code-sdk` / `claude_code_sdk` | `claude-agent-sdk` / `claude_agent_sdk` |
| `ClaudeCodeOptions` | `ClaudeAgentOptions` |
| System prompt defaulted to `claude_code` preset | System prompt now minimal (empty); opt in with `{ type: 'preset', preset: 'claude_code' }` |
| `settingSources` defaulted to empty | `settingSources` now defaults to full filesystem (user + project + local) |

V2 session API (`unstable_v2_createSession`, `unstable_v2_resumeSession`) removed in TS SDK 0.3.142; use `query()` with session options instead.

### Authentication

| Provider | Env Vars |
| :--- | :--- |
| Direct (Anthropic API) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `ANTHROPIC_BEDROCK_BASE_URL` (or `AWS_*`) |
| Google Vertex AI | `ANTHROPIC_VERTEX_PROJECT_ID`, `CLOUD_ML_REGION` |
| Azure AI Foundry | `ANTHROPIC_AZURE_BASE_URL` |
| Proxy | `ANTHROPIC_BASE_URL` |

### TypeScript-Only Functions

`startup()` — pre-warm CLI subprocess; returns `WarmQuery` handle. `resolveSettings()` — inspect effective settings without spawning Claude. `applyFlagSettings()` — change settings at runtime on a live `Query`. `setPermissionMode()`, `setModel()` — runtime changes on live `Query`. `interrupt()` — cancel current operation.

### Python-Only

`ClaudeSDKClient` — persistent session client with `async with ClaudeSDKClient(options) as client: await client.query(prompt)` then `async for message in client.receive_response()`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK capabilities, built-in tools, comparison vs Client SDK/CLI/Managed Agents, install, authentication
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step setup, first query, permission modes table, tools-to-capabilities table
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — Loop mechanics, message types, tool execution, turns, budget, effort levels, context compaction, result subtypes
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md loading, hooks comparison, feature matrix
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `model_usage`, cache token fields, deduplication, prompt caching env var
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` helper, `createSdkMcpServer`, `readOnlyHint`, error handling, image/resource return types
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Enable, `rewindFiles()`, checkpoint patterns, limitations
- [Hooks](references/claude-code-agent-sdk-hooks.md) — 20 hook events, `HookMatcher`, callback signatures, permission decisions, async hooks, examples
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns, container sizing, multi-tenant isolation
- [MCP Servers](references/claude-code-agent-sdk-mcp.md) — Transport types (stdio/HTTP/SSE/in-process), wildcard allow, auth, tool search
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Package renames, `ClaudeCodeOptions` → `ClaudeAgentOptions`, system prompt and `settingSources` defaults
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Minimal/preset/custom starting points, `excludeDynamicSections`, output styles
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry env vars, span names, W3C trace context, resource tagging
- [Permissions](references/claude-code-agent-sdk-permissions.md) — 6-step evaluation order, allow/deny rules, all permission modes, `canUseTool`
- [Plugins](references/claude-code-agent-sdk-plugins.md) — `plugins` option, namespacing, plugin structure, auto-discovery
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — `query()`, `ClaudeSDKClient`, `tool()`, `create_sdk_mcp_server()`, `ClaudeAgentOptions`, all message types, session functions
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Threat model, isolation technologies, credential management, filesystem config
- [Sessions](references/claude-code-agent-sdk-sessions.md) — `continue`/`resume`/`fork`, `ClaudeSDKClient`, session ID capture, cross-host resume
- [Skills](references/claude-code-agent-sdk-skills.md) — `skills` option, filesystem locations, `settingSources` requirement, tool restrictions, troubleshooting
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Built-in commands, custom commands format, arguments, bash execution, file references
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` structure, text/tool-call streaming, message flow
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — `AsyncGenerator<SDKUserMessage>` input, image uploads, interruption, single-message limitations
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — `outputFormat`/`output_format`, Zod/Pydantic schemas, `structured_output` field, error handling
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition` fields, inheritance, model aliases, `Workflow` tool, background vs foreground
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate`/`TaskUpdate` monitoring, migration from `TodoWrite`, `taskId` from tool results
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — `ENABLE_TOOL_SEARCH` values, auto threshold, Vertex AI behavior, optimize discovery
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, `Options` type (all fields), `Query` object, message types, session functions
- [TypeScript V2 Preview (removed)](references/claude-code-agent-sdk-typescript-v2-preview.md) — Removed V2 API reference for `unstable_v2_createSession`; migrate to `query()`
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, tool approval responses, `AskUserQuestion` handling, question format, option previews
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface, `InMemorySessionStore`, S3/Redis/Postgres adapters, dual-write architecture, conformance suite

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
- MCP Servers: https://code.claude.com/docs/en/agent-sdk/mcp.md
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
