---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building custom agents in TypeScript and Python with tools, hooks, subagents, MCP, sessions, permissions, streaming, structured outputs, observability, and secure deployment.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

The Agent SDK lets you build custom agents in TypeScript and Python that use Claude Code's built-in tools (Read, Write, Edit, Bash, Monitor, Glob, Grep, WebSearch, WebFetch, AskUserQuestion).

### Installation

```bash
npm install @anthropic-ai/claude-agent-sdk   # TypeScript
pip install claude-agent-sdk                  # Python
```

Auth: `ANTHROPIC_API_KEY` or third-party (Bedrock, Vertex AI, Azure).

### Core pattern

`query({ prompt, options })` yields `SystemMessage` (init) → `AssistantMessage` (per turn) → `ResultMessage`.

Key options: `allowedTools`, `permissionMode`, `systemPrompt`, `mcpServers`, `maxTurns`, `maxBudgetUsd`.

### Migration from claude-code-sdk

| Change | Old | New |
| :----- | :-- | :-- |
| TS package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Python options class | `ClaudeCodeOptions` | `ClaudeAgentOptions` |
| System prompt | Defaults to Claude Code preset | Must set explicitly: `{ type: "preset", preset: "claude_code" }` |
| Settings sources | Loaded by default | Must set `settingSources: ["user", "project", "local"]` |

Versions: npm v0.2.0, pip v0.0.42+.

### Agent loop message types

| Message type | When |
| :----------- | :--- |
| `SystemMessage` | Session init (`"init"`) or compaction boundary |
| `AssistantMessage` | After each Claude response |
| `UserMessage` | After tool execution |
| `StreamEvent` | Partial messages when `includePartialMessages: true` |
| `ResultMessage` | End of loop; check `subtype` |

Result subtypes: `success`, `error_max_turns`, `error_max_budget_usd`, `error_during_execution`, `error_max_structured_output_retries`.

Limits: `max_turns`, `max_budget_usd`, `effort` (low/medium/high/xhigh/max).

### Sessions

| Use case | Approach |
| :------- | :------- |
| One-shot task | Single `query()` call |
| Multi-turn (same process) | `ClaudeSDKClient` (Python) or `continue: true` (TS) |
| Resume specific session | `resume: session_id` |
| Branch alternative path | `fork_session: true` |
| Stateless (TS) | `persistSession: false` |

Session ID: from `ResultMessage.session_id` or `SystemMessage.data.session_id`.

Utilities: `listSessions()`, `getSessionMessages()`, `get_session_info()`, `renameSession()`, `tagSession()`.

Cross-host resume: mirror transcripts via `SessionStore` adapter.

### Streaming vs single mode

| | Streaming (recommended) | Single message |
| :- | :-- | :-- |
| Session | Persistent, interactive | One-shot |
| Images | Yes | No |
| Queued messages | Yes | No |
| Hooks | Yes | No |
| Real-time feedback | Yes | No |
| Good for | Most agents | Lambda/stateless |

Enable streaming events: `includePartialMessages: true` (TS) / `include_partial_messages: True` (Python).

Stream event types: `message_start`, `content_block_delta` (`text_delta` or `input_json_delta`), `content_block_stop`, `message_stop`.

Limitation: extended thinking and structured output don't emit StreamEvents.

### TypeScript V2 preview (unstable)

```ts
await using session = unstable_v2_createSession(options);
await session.send(msg);
for await (const event of session.stream()) { ... }
```

APIs: `unstable_v2_createSession()`, `unstable_v2_resumeSession()`, `unstable_v2_prompt()`. Missing: session forking, some advanced input patterns.

### Custom tools

| Part | Description |
| :--- | :---------- |
| Name | Unique identifier (`mcp__<server>__<tool>` format) |
| Description | What the tool does (Claude uses to decide when to call) |
| Input schema | Zod (TS) or dict (Python); JSON Schema for complex types |
| Handler | Async function returning `{content: [...], isError?: bool}` |

Annotations: `readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`.

### MCP

Transport types: `stdio` (local process), HTTP/SSE (cloud-hosted), SDK MCP (in-process via `createSdkMcpServer()`).

Auth: env vars, HTTP headers, OAuth2 access tokens.

Tool naming: `mcp__<servername>__<toolname>`; wildcards: `mcp__github__*`.

Check `mcp_servers` in init message for `status` field on error.

### Subagents

| Field | Required | Notes |
| :---- | :------- | :---- |
| `description` | Yes | When to use this agent |
| `prompt` | Yes | System instructions |
| `tools` | No | Restrict or inherit |
| `model` | No | `'sonnet'`, `'opus'`, `'haiku'`, `'inherit'` |
| `skills` | No | Preload skill names |
| `mcpServers` | No | MCP config |
| `maxTurns` | No | Agentic turns limit |
| `background` | No | Non-blocking execution |
| `effort` | No | Reasoning level |
| `permissionMode` | No | Tool execution mode |

Invocation: automatic (Claude decides based on description) or explicit ("Use the `<name>` agent to...").

Detect: look for `tool_use` blocks with `name: "Agent"` or `"Task"`.

Subagent receives: own prompt, CLAUDE.md, tools, skills. Does NOT receive: parent conversation history or system prompt.

### System prompts (4 methods)

1. **CLAUDE.md** — project-level markdown in root or `.claude/`
2. **Output styles** — saved configs at `~/.claude/output-styles/` with YAML frontmatter
3. **`systemPrompt` with append** — `{ type: "preset", preset: "claude_code", append: "..." }`; use `excludeDynamicSections: true` for cache reuse across machines
4. **Custom string** — complete replacement (loses built-in tools if not included)

### Permissions

Evaluation order: Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

| Mode | Behavior |
| :--- | :------- |
| `default` | No auto-approvals; triggers `canUseTool` |
| `dontAsk` | Deny instead of prompting |
| `acceptEdits` | Auto-approve file edits and filesystem ops |
| `bypassPermissions` | Approve all tools (use with caution) |
| `plan` | No tool execution; planning only |
| `auto` | Model classifier approves/denies (TS only) |

Rules: `allowed_tools`, `disallowed_tools` via options or `settings.json`.

Dynamic mode change: `setPermissionMode()` / `set_permission_mode()` mid-session.

Subagent inheritance: when parent uses `bypassPermissions`, `acceptEdits`, or `auto`.

### User input

`canUseTool` callback fires for tool approval or `AskUserQuestion`:

```ts
{ behavior: "allow" | "deny", updatedInput?: ..., message?: ... }
```

`AskUserQuestion` input: `{ questions: [{ question, header, options: [{ label, description }], multiSelect }] }`.

Response: `{ answers: { questionText: selectedLabel } }`; multi-select joins with `", "`.

### File checkpointing

| Python | TypeScript | Effect |
| :----- | :--------- | :----- |
| `enable_file_checkpointing=True` | `enableFileCheckpointing: true` | Track Write/Edit/NotebookEdit |
| `extra_args={"replay-user-messages": None}` | `extraArgs: {"replay-user-messages": null}` | Receive checkpoint UUIDs |

Tools tracked: Write, Edit, NotebookEdit (NOT Bash).

Workflow: enable + capture UUID → store session ID → resume + call `rewind_files(uuid)`.

### Hooks

| Event | Triggers | Example use |
| :---- | :------- | :---------- |
| `PreToolUse` | Before tool call | Block dangerous commands |
| `PostToolUse` | After completion | Audit logs |
| `PostToolUseFailure` | Tool error | Handle failures |
| `UserPromptSubmit` | Prompt submission | Inject context |
| `Stop` | Agent stop | Save state |
| `SubagentStart/Stop` | Subagent lifecycle | Track parallel tasks |
| `SessionStart/End` | Session lifecycle (TS only) | Init/cleanup |
| `Notification` | Status updates | Slack forwarding |

Hook matcher: regex pattern on tool name (empty = all).

Hook output:
```json
{
  "systemMessage": "...",
  "continue_": true,
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask|defer",
    "updatedInput": {},
    "permissionDecisionReason": "..."
  }
}
```

Async mode: return `{ async_: true, asyncTimeout: 30000 }` for fire-and-forget side effects.

### Observability

Enable: `CLAUDE_CODE_ENABLE_TELEMETRY=1` + OTLP exporter env vars.

Span types: `claude_code.interaction`, `claude_code.llm_request`, `claude_code.tool`, `claude_code.hook`.

Supported backends: Honeycomb, Datadog, Grafana, Langfuse.

Optional sensitive logging: `OTEL_LOG_USER_PROMPTS`, `OTEL_LOG_TOOL_DETAILS`, `OTEL_LOG_TOOL_CONTENT`, `OTEL_LOG_RAW_API_BODIES`.

### Cost tracking

- `total_cost_usd` (estimate); per-model via `modelUsage` / `model_usage`
- Track `cache_creation_input_tokens` and `cache_read_input_tokens` separately
- Each `query()` returns its own total; manually accumulate for multi-call sessions

### Tool search

- Default on; `ENABLE_TOOL_SEARCH=false` to disable; `auto` activates when tools exceed 10% of context
- Max 10,000 tools; returns 3-5 most relevant per search
- Requires Sonnet 4+ or Opus 4+ (Haiku not supported)

### Hosting

Runtime: Python 3.10+ or Node.js 18+; 1 GiB RAM, 5 GiB disk, 1 CPU recommended.

Sandbox providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel.

Deployment patterns: ephemeral, long-running, hybrid, single container.

### Secure deployment

| Component | Options |
| :-------- | :------ |
| Isolation | Sandbox runtime, Docker, gVisor, VMs (Firecracker) |
| Permissions | Glob patterns, allow/deny rules, `permissionMode` |
| Filesystem | Read-only mounts, tmpfs, avoid `.env`/`.ssh`/`.aws` |
| Network | Unix socket proxy, domain allowlists, TLS-terminating proxy |

### Skills in SDK

- Packaged as `SKILL.md` files in `.claude/skills/`
- Require `"Skill"` in `allowedTools`; must be filesystem artifacts (no programmatic registration)
- Config: `settingSources: ["user", "project"]` + `allowedTools: ["Skill", ...]`

### Plugins

Loading: `plugins: [{ type: "local", path: "./my-plugin" }]`.

Skills namespaced as `/plugin-name:skill-name`. Verify via init message `plugins` and `slash_commands` fields.

### Structured outputs

Option: `output_format: { type: "json_schema", schema: ... }` (Zod/Pydantic auto-converts).

Access: `ResultMessage.structured_output` on success. Auto-retries on mismatch; check `subtype === "success"` before reading.

### Todo tracking

Lifecycle: `pending` → `in_progress` → `completed` → `removed`.

Auto-created for complex multi-step tasks; monitor via `TodoWrite` tool in message stream.

### TypeScript API

```ts
query({ prompt, options })          // AsyncGenerator<SDKMessage>
startup(options)                    // Promise<WarmQuery> — pre-warm subprocess
tool(name, desc, schema, handler)   // SdkMcpToolDefinition
createSdkMcpServer({ name, tools }) // McpServerConfig
```

Query instance methods: `interrupt()`, `rewindFiles(uuid)`, `setPermissionMode()`, `setModel()`, `close()`.

### Python API

```python
query(prompt, options)          # AsyncIterator[Message]
ClaudeSDKClient()               # Context manager for continuous sessions
tool()(fn)                      # Decorator with input_schema
create_sdk_mcp_server(name, ...) # McpServerConfig
```

`ClaudeSDKClient` methods: `query()`, `receive_response()`, `interrupt()`, `set_permission_mode()`, `set_model()`, `rewind_files()`, `reconnect_mcp_server()`, `toggle_mcp_server()`, `stop_task()`.

## Full Documentation

For the complete official documentation, see the reference files:

- [SDK Overview](references/claude-code-agent-sdk-overview.md) — introduction, available tools, auth setup, and capabilities overview
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — installation, first agent, key options, and permission modes
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — message flow, types, result subtypes, limits, and context compaction
- [Sessions](references/claude-code-agent-sdk-sessions.md) — multi-turn, resume, fork, stateless, cross-host patterns, and utilities
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — comparison, use cases, and tradeoffs
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — enabling partial messages and processing stream events
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable v2 session API
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — defining, registering, and annotating custom tools
- [MCP](references/claude-code-agent-sdk-mcp.md) — transports, auth, tool naming, SDK MCP servers
- [Subagents](references/claude-code-agent-sdk-subagents.md) — AgentDefinition fields, invocation, and what subagents inherit
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — 4 methods with tradeoffs
- [Permissions](references/claude-code-agent-sdk-permissions.md) — evaluation order, modes, rules, and dynamic changes
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback and AskUserQuestion tool
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — setup, tracked tools, and restore workflow
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matcher patterns, output format, async mode
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry setup, span types, backends, sensitive logging
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — per-invocation and per-session cost accumulation
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — dynamic tool discovery for large tool sets
- [Hosting](references/claude-code-agent-sdk-hosting.md) — runtime requirements, sandbox providers, deployment patterns
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — isolation, permissions, filesystem, and network hardening
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — CLAUDE.md, skills, hooks, and settings sources in SDK
- [Skills](references/claude-code-agent-sdk-skills.md) — packaging and loading skills from the SDK
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading local plugins and namespacing
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — built-in and custom slash commands, variables
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON schema, Zod/Pydantic, validation
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — lifecycle, auto-creation, monitoring
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — full TypeScript API reference
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — full Python API reference with ClaudeSDKClient
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from claude-code-sdk to claude-agent-sdk

## Sources

- SDK Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
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
