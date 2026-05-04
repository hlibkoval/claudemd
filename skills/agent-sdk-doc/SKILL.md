---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents with Python and TypeScript, including the agent loop, sessions, permissions, hooks, MCP, custom tools, subagents, streaming, structured outputs, cost tracking, observability, hosting, and secure deployment.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK) — a Python and TypeScript library for building autonomous AI agents that can read files, run commands, search the web, edit code, and more.

## Quick Reference

### Installation

```bash
# TypeScript
npm install @anthropic-ai/claude-agent-sdk

# Python (uv)
uv add claude-agent-sdk

# Python (pip)
pip install claude-agent-sdk
```

Set `ANTHROPIC_API_KEY` before running. Also supports Amazon Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Google Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), and Microsoft Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Minimal Example

```python
# Python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

```typescript
// TypeScript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  if ("result" in message) console.log(message.result);
}
```

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run shell commands, scripts, git operations |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `Monitor` | Watch a background script and react to each output line |
| `Agent` | Spawn subagents for focused subtasks |
| `AskUserQuestion` | Ask the user clarifying questions |
| `ToolSearch` | Dynamically load tools on demand |
| `TodoWrite` | Track tasks within the agent loop |

### ClaudeAgentOptions / Options — Key Fields

| Field (Python / TypeScript) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Auto-approve these tools (no permission prompt) |
| `disallowed_tools` / `disallowedTools` | Always block these tools |
| `permission_mode` / `permissionMode` | Global permission behavior (see table below) |
| `max_turns` / `maxTurns` | Cap the number of tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | Cap spend before stopping |
| `effort` | Reasoning depth: `"low"` / `"medium"` / `"high"` / `"xhigh"` / `"max"` |
| `model` | Model ID, e.g. `"claude-sonnet-4-6"` |
| `system_prompt` / `systemPrompt` | Custom system prompt string or preset |
| `mcp_servers` / `mcpServers` | MCP server configs (key = server name) |
| `hooks` | Callback hooks keyed by event name |
| `agents` | Subagent definitions keyed by agent name |
| `setting_sources` / `settingSources` | Which filesystem sources to load: `"user"`, `"project"`, `"local"` |
| `resume` | Session ID to resume |
| `fork_session` / `forkSession` | Fork the resumed session instead of continuing it |
| `continue_conversation` / `continue` | Resume the most recent session (no ID needed) |
| `include_partial_messages` / `includePartialMessages` | Enable token-by-token streaming |
| `output_format` / `outputFormat` | Structured output schema (`{"type": "json_schema", "schema": {...}}`) |

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `"default"` | Unmatched tools trigger `canUseTool` callback; no callback = deny |
| `"acceptEdits"` | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, `mv`, `cp`, `sed`) |
| `"dontAsk"` | Denies anything not pre-approved by `allowedTools` or rules |
| `"plan"` | No tool execution; Claude produces a plan only |
| `"bypassPermissions"` | All tools run without prompts — use only in isolated environments |
| `"auto"` (TypeScript only) | Model classifier approves or denies each call |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

### Message Types

| Type | Python class | TS `type` field | When emitted |
| :--- | :--- | :--- | :--- |
| System / init | `SystemMessage` (subtype `"init"`) | `"system"` | First message; contains `session_id` |
| Assistant | `AssistantMessage` | `"assistant"` | After each Claude response turn |
| User (tool result) | `UserMessage` | `"user"` | After each tool execution |
| Stream event | `StreamEvent` | `"stream_event"` | When `includePartialMessages` is enabled |
| Result | `ResultMessage` | `"result"` | Final message; contains result text, cost, session ID |
| Compact boundary | `SystemMessage` (subtype `"compact_boundary"`) | `SDKCompactBoundaryMessage` | When context was compacted |

### ResultMessage Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :---: |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes include `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Sessions

| Approach | How | Use when |
| :--- | :--- | :--- |
| Single query | One `query()` call, no options | One-shot task |
| Auto continue (Python) | `ClaudeSDKClient` — tracks session internally | Multi-turn in one process |
| Auto continue (TypeScript) | `continue: true` on subsequent `query()` calls | Multi-turn in one process |
| Resume by ID | `resume=session_id` | Return to a specific past session |
| Fork | `resume=id` + `fork_session=True` | Try alternative without losing original |

Session files live at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.

### Hooks — Available Events

| Hook event | Python | TypeScript | When it fires |
| :--- | :---: | :---: | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes — can block or modify |
| `PostToolUse` | Yes | Yes | After a tool returns |
| `PostToolUseFailure` | Yes | Yes | After a tool execution failure |
| `PostToolBatch` | No | Yes | After a full batch of tool calls resolves |
| `UserPromptSubmit` | Yes | Yes | When a prompt is sent |
| `Stop` | Yes | Yes | When the agent finishes |
| `SubagentStart` | Yes | Yes | When a subagent spawns |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before context compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would show |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |

**Hook callback signature (Python):** `async def cb(input_data, tool_use_id, context) -> dict`
**Hook callback signature (TypeScript):** `async (input, toolUseID, { signal }) => {...}`

Return `{}` to allow without changes. Return `{ hookSpecificOutput: { permissionDecision: "deny", ... } }` to block.

**Matcher format:**

```python
# Python
HookMatcher(matcher="Write|Edit", hooks=[my_callback])

# TypeScript
{ matcher: "Write|Edit", hooks: [myCallback] }
```

MCP tool names match as `mcp__<server>__<action>`.

### MCP Servers

| Transport | Use for | Config key |
| :--- | :--- | :--- |
| `stdio` | Local process (`command` + `args`) | Default (no `type` needed) |
| `"sse"` | Remote SSE URL | `type: "sse"`, `url: "..."` |
| `"http"` | Remote HTTP URL | `type: "http"`, `url: "..."` |
| SDK MCP server | In-process custom tools | Pass object from `createSdkMcpServer` |

MCP tool naming: `mcp__<server-name>__<tool-name>`. Use `"mcp__github__*"` wildcard in `allowedTools` to allow all tools from a server.

### Custom Tools

```python
# Python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("get_temperature", "Get temperature at a location", {"latitude": float, "longitude": float})
async def get_temperature(args):
    return {"content": [{"type": "text", "text": "72°F"}]}

weather_server = create_sdk_mcp_server(name="weather", version="1.0.0", tools=[get_temperature])
# Pass as: mcp_servers={"weather": weather_server}, allowed_tools=["mcp__weather__get_temperature"]
```

Return `{ "content": [...], "is_error": True }` (Python) / `{ content: [...], isError: true }` (TypeScript) to report a tool error without stopping the loop.

**Tool annotations** (fifth arg to `tool()` in TypeScript, `annotations=` kwarg in Python):

| Annotation | Default | Effect |
| :--- | :--- | :--- |
| `readOnlyHint` | `false` | Enables parallel execution with other read-only tools |
| `destructiveHint` | `true` | Informational only |
| `idempotentHint` | `false` | Informational only |

### Subagents (AgentDefinition)

| Field | Required | Description |
| :--- | :---: | :--- |
| `description` | Yes | When to use this agent (Claude reads this to decide) |
| `prompt` | Yes | The subagent's system prompt |
| `tools` | No | Allowed tools (omit = inherit all from parent) |
| `disallowedTools` | No | Tools to remove from the subagent's set |
| `model` | No | Model alias or ID (`"sonnet"`, `"opus"`, `"haiku"`, or full ID) |
| `maxTurns` | No | Turn limit for this subagent |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Reasoning effort level |
| `permissionMode` | No | Permission mode for this subagent |

Include `"Agent"` in parent's `allowedTools` — subagents are invoked via the Agent tool. Subagents cannot spawn further subagents.

### Streaming Output

Enable with `include_partial_messages=True` (Python) or `includePartialMessages: true` (TypeScript). Look for `StreamEvent` messages, then check `event["type"] == "content_block_delta"` and `delta["type"] == "text_delta"` for text chunks.

### Structured Outputs

```python
options = ClaudeAgentOptions(
    output_format={"type": "json_schema", "schema": my_schema}
)
# Result: message.structured_output contains validated dict
```

Use Pydantic's `.model_json_schema()` (Python) or Zod's `z.toJSONSchema()` (TypeScript) to generate schemas. Incompatible with streaming.

### Cost Tracking

- `ResultMessage.total_cost_usd` — estimated total cost for this `query()` call
- `ResultMessage.usage` — cumulative token counts (`input_tokens`, `output_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`)
- `ResultMessage.model_usage` (TypeScript) / `result.model_usage` (Python) — per-model breakdown
- Per-step usage is on each `AssistantMessage`; deduplicate by message ID when parallel tools are used

`total_cost_usd` is a client-side estimate — use Anthropic Console for authoritative billing.

### Observability (OpenTelemetry)

Enable with env vars:

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1   # required for traces
OTEL_TRACES_EXPORTER=otlp
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=http://collector.example.com:4318
```

Key span names: `claude_code.interaction`, `claude_code.llm_request`, `claude_code.tool`, `claude_code.hook`.

In TypeScript, pass env vars in `options.env` as `{ ...process.env, ...otelEnv }` (replaces inherited env). In Python, `env` merges on top of inherited env.

### Hosting Patterns

| Pattern | Description | Best for |
| :--- | :--- | :--- |
| Ephemeral sessions | New container per task, destroyed on completion | One-off tasks |
| Long-running sessions | Persistent container, multiple agent processes | Email agents, chat bots |
| Hybrid sessions | Ephemeral + session resume from storage | Intermittent multi-step tasks |
| Single container | Multiple agents in one container | Agent simulations |

Recommended resources: 1 GiB RAM, 5 GiB disk, 1 CPU. Requires outbound HTTPS to `api.anthropic.com`.

### Migration from Claude Code SDK

| | Old | New |
| :--- | :--- | :--- |
| TS package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Python import | `from claude_code_sdk import query, ClaudeCodeOptions` | `from claude_agent_sdk import query, ClaudeAgentOptions` |

Breaking changes in v0.1.0: system prompt no longer defaults to Claude Code preset (use `systemPrompt: { type: "preset", preset: "claude_code" }` to restore); settings sources no longer loaded by default (pass `settingSources: ["user", "project", "local"]` to restore).

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK capabilities, built-in tools, capabilities overview, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step first agent, tool combinations, permission mode reference
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, message types, context window, compaction, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full TypeScript API, all types and options
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full Python API, all types and options
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, ClaudeSDKClient, cross-host sessions
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, dynamic mode changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, callback API, examples, troubleshooting
- [MCP](references/claude-code-agent-sdk-mcp.md) — transport types, tool search, auth, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — tool(), createSdkMcpServer, annotations, error handling, images/resources
- [Subagents](references/claude-code-agent-sdk-subagents.md) — AgentDefinition, invocation, context inheritance, resuming subagents
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — StreamEvent handling, text and tool call streaming
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — input modes comparison
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod/Pydantic, error handling
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — per-step usage, per-model breakdown, cache tokens
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, log events, sensitive data controls
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container requirements, deployment patterns, FAQ
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — isolation, least privilege, credential management, network controls
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — CLAUDE.md, skills, slash commands, plugins via settingSources
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — system prompt presets and customization
- [Skills](references/claude-code-agent-sdk-skills.md) — loading and using skills in SDK agents
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — using slash commands (e.g. `/compact`) as SDK inputs
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — TodoWrite tool and task tracking
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred tool loading for large tool sets
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes
- [Plugins](references/claude-code-agent-sdk-plugins.md) — using plugins with the SDK
- [User input](references/claude-code-agent-sdk-user-input.md) — canUseTool callback, AskUserQuestion, approval flows
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable V2 API with createSession/send/stream
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from claude-code-sdk to claude-agent-sdk

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
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
- Python SDK: https://code.claude.com/docs/en/agent-sdk/python.md
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
- TypeScript SDK: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
