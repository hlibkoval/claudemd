---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: building, configuring, and deploying production AI agents in Python and TypeScript.

## Quick Reference

### Installation

| Language | Package | Requirement |
|:---------|:--------|:------------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

Set `ANTHROPIC_API_KEY` before running. Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), Azure (`CLAUDE_CODE_USE_FOUNDRY=1`), and Claude Platform on AWS (`CLAUDE_CODE_USE_ANTHROPIC_AWS=1`).

### Core API: `query()`

The main entry point. Returns an async iterator of messages as the agent works.

```python
# Python
from claude_agent_sdk import query, ClaudeAgentOptions
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
// TypeScript
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({ prompt: "...", options: { ... } })) { ... }
```

### Message Types

| Type | Python class | TS `type` field | Contents |
|:-----|:-------------|:----------------|:---------|
| System init | `SystemMessage` (subtype `init`) | `"system"` | `session_id`, working dir |
| Assistant turn | `AssistantMessage` | `"assistant"` | `content` array of text/tool blocks |
| Tool result | `ToolResultMessage` | `"tool_result"` | Tool output |
| Final result | `ResultMessage` | `"result"` | `subtype` (`success`/`error_*`), `result`, `total_cost_usd`, `session_id` |
| Stream event | `StreamEvent` | `"stream_event"` | Raw API streaming events (requires `includePartialMessages`) |

Result subtypes for errors: `error_max_turns`, `error_max_budget_usd`, `error_api_error`, `error_unknown`.

### `ClaudeAgentOptions` / `Options` Key Fields

| Python field | TypeScript field | Description |
|:-------------|:----------------|:------------|
| `allowed_tools` | `allowedTools` | Tools pre-approved (no prompt). List names like `"Read"`, `"Bash"`, `"mcp__server__tool"` |
| `disallowed_tools` | `disallowedTools` | Bare name removes tool from context; scoped rule (`"Bash(rm *)"`) denies matching calls only |
| `permission_mode` | `permissionMode` | See permission modes table below |
| `system_prompt` | `systemPrompt` | Custom system prompt (appended or replaces; see modifying-system-prompts) |
| `mcp_servers` | `mcpServers` | Dict of MCP server configs (stdio, HTTP, or in-process SDK servers) |
| `hooks` | `hooks` | Dict of hook event → list of matchers with callbacks |
| `agents` | `agents` | Dict of subagent name → `AgentDefinition` |
| `resume` | `resume` | Session ID to resume |
| `continue_conversation` | `continue` | Resume most recent session in cwd without tracking an ID |
| `fork_session` | `forkSession` | Fork the resumed session into a new independent session |
| `max_turns` | `maxTurns` | Cap the number of agent turns |
| `max_budget_usd` | `maxBudgetUsd` | Cap total cost |
| `include_partial_messages` | `includePartialMessages` | Stream raw API events for real-time output |
| `cwd` | `cwd` | Working directory for the agent |
| `env` | `env` | Environment variables passed to the agent process |
| `setting_sources` | `settingSources` | Which settings files to load: `"project"`, `"user"`, `"local"`, `"enterprise"` |
| `persist_session` | `persistSession` | `false` = in-memory only (TypeScript only) |
| `tools` | `tools` | Restrict which built-in tools are available (array of tool names) |

### Permission Modes

| Mode | Behavior | Best for |
|:-----|:---------|:---------|
| `default` | No auto-approvals; unmatched tools call `canUseTool` callback | Interactive apps |
| `acceptEdits` | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, `mv`, `cp`, `sed`) | Trusted dev workflows |
| `dontAsk` | Anything not pre-approved is denied; `canUseTool` never called | Locked-down headless agents |
| `bypassPermissions` | All tools run without prompts | Sandboxed CI; trusted envs only |
| `plan` | Read-only tools only; Claude proposes without editing | Code review / planning |
| `auto` (TS only) | Model classifier approves/denies each tool call | Autonomous agents with guardrails |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

Warning: `bypassPermissions` grants full system access. `allowed_tools` does not constrain it — use `disallowed_tools` to block specific tools in bypass mode. Subagents inherit the parent's permission mode and cannot override it.

### Built-in Tools

| Tool | What it does |
|:-----|:-------------|
| `Read` | Read any file |
| `Write` | Create new files |
| `Edit` | Precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web pages |
| `Monitor` | Watch a background script, react to each output line |
| `AskUserQuestion` | Ask the user a clarifying question |
| `Agent` | Invoke a subagent |

### Sessions

Sessions persist the conversation history to disk at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.

| What you need | Approach |
|:--------------|:---------|
| One-shot task | Plain `query()` — no session management needed |
| Multi-turn in one process (Python) | `ClaudeSDKClient` — tracks session ID automatically |
| Multi-turn in one process (TypeScript) | `query()` with `continue: true` on subsequent calls |
| Resume specific past session | Capture `session_id` from `ResultMessage`; pass to `resume` |
| Try alternative without losing original | Pass `forkSession: true` alongside `resume` |
| Stateless (TS only) | `persistSession: false` |

Session files are machine-local. To resume across hosts: copy the JSONL file to the same path on the target, or use a `SessionStore` adapter for shared remote storage.

Utility functions: `listSessions()` / `list_sessions()`, `getSessionMessages()` / `get_session_messages()`, `getSessionInfo()` / `get_session_info()`, `renameSession()` / `rename_session()`, `tagSession()` / `tag_session()`.

### Hooks

Hooks are callback functions that intercept agent events.

```python
# Python
options = ClaudeAgentOptions(
    hooks={"PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])]}
)
```

```typescript
// TypeScript
options = { hooks: { PreToolUse: [{ matcher: "Write|Edit", hooks: [myCallback] }] } }
```

#### Available Hook Events

| Event | Python | TS | Trigger |
|:------|:------:|:--:|:--------|
| `PreToolUse` | Yes | Yes | Before a tool call (can block/modify) |
| `PostToolUse` | Yes | Yes | After a tool returns a result |
| `PostToolUseFailure` | Yes | Yes | After a tool fails |
| `PostToolBatch` | No | Yes | After a full batch of tool calls |
| `UserPromptSubmit` | Yes | Yes | When a user prompt is submitted |
| `MessageDisplay` | No | Yes | When an assistant message with text completes |
| `Stop` | Yes | Yes | When agent execution stops |
| `SubagentStart` | Yes | Yes | When a subagent initializes |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before conversation compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would show |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |
| `Setup` | No | Yes | Session setup/maintenance |

#### Matcher Patterns

- Pipe-separated exact list: `"Write|Edit"` matches those tools exactly
- `*` or omitted: matches every occurrence of the event
- Any other character: treated as a regex (e.g., `"^mcp__"` matches all MCP tools)
- MCP tools: named `mcp__<server>__<action>`

#### Callback Output

Return `{}` to allow with no changes. Key `hookSpecificOutput` fields for `PreToolUse`:

| Field | Values | Effect |
|:------|:-------|:-------|
| `permissionDecision` | `"allow"`, `"deny"`, `"ask"`, `"defer"` | Control whether the tool runs |
| `permissionDecisionReason` | string | Shown to model when denying |
| `updatedInput` | object | Replace tool input (requires `permissionDecision: "allow"` or `"ask"`) |

For `PostToolUse`: set `additionalContext` to inject info into the tool result, or `updatedToolOutput` to replace the tool's output.

Top-level fields (all events): `systemMessage` (shown to user), `continue` (`continue_` in Python) to stop agent after hook.

For async side effects (logging), return `{ async: true, asyncTimeout: 30000 }` (Python: `async_`).

When multiple hooks apply: `deny` beats `defer` beats `ask` beats `allow`.

### Custom Tools (In-process MCP Server)

```python
# Python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("tool_name", "Description", {"param": float})
async def my_tool(args): return {"content": [{"type": "text", "text": "result"}]}

server = create_sdk_mcp_server(name="myserver", version="1.0.0", tools=[my_tool])
options = ClaudeAgentOptions(mcp_servers={"myserver": server}, allowed_tools=["mcp__myserver__tool_name"])
```

```typescript
// TypeScript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";
const myTool = tool("tool_name", "Description", { param: z.number() }, async (args) => ({
  content: [{ type: "text", text: "result" }]
}));
const server = createSdkMcpServer({ name: "myserver", version: "1.0.0", tools: [myTool] });
```

Custom tool name format: `mcp__{server_name}__{tool_name}`. Use `mcp__server__*` wildcard in `allowedTools` to approve all tools on a server.

Tool handler return fields: `content` (required, array of `text`/`image`/`resource` blocks), `isError` (`is_error` in Python), `structuredContent` (TypeScript only for in-process servers).

Tool annotations (`ToolAnnotations`): `readOnlyHint` (allows parallel calls), `destructiveHint`, `idempotentHint`, `openWorldHint`. Pass as fifth arg in TS or `annotations=` in Python.

Error handling: return `isError: true` instead of throwing — keeps the agent loop alive. Uncaught exceptions stop the loop.

### Subagents

Define subagents programmatically via the `agents` option. Include `"Agent"` in `allowedTools` to auto-approve subagent invocations.

```python
# Python
from claude_agent_sdk import AgentDefinition
agents={"code-reviewer": AgentDefinition(
    description="Use for code quality and security reviews.",
    prompt="You are a code review specialist...",
    tools=["Read", "Glob", "Grep"],
)}
```

```typescript
// TypeScript
agents: {
  "code-reviewer": { description: "Use for...", prompt: "You are...", tools: ["Read", "Glob", "Grep"] }
}
```

Messages from within a subagent include `parent_tool_use_id` to track which subagent produced them.

Subagents run in isolated contexts — intermediate tool calls stay inside the subagent, only the final message returns to the parent. They can run in parallel for speed.

### External MCP Servers

Configure external MCP servers (stdio, HTTP, or SSE) via `mcpServers`:

```python
mcp_servers={
    "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},  # stdio
    "remote": {"type": "http", "url": "https://example.com/mcp"},          # HTTP
}
```

### Streaming Output

Enable real-time token streaming with `includePartialMessages: true` / `include_partial_messages=True`. This yields additional `StreamEvent` messages with raw API events. Look for `content_block_delta` events where `delta.type` is `text_delta` to get text chunks.

### Observability (OpenTelemetry)

The SDK exports telemetry through environment variables passed to the agent process:

| Variable | Purpose |
|:---------|:--------|
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Enable telemetry (required) |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Enable traces (beta) |
| `OTEL_TRACES_EXPORTER=otlp` | Export traces |
| `OTEL_METRICS_EXPORTER=otlp` | Export metrics (tokens, cost, tool decisions) |
| `OTEL_LOGS_EXPORTER=otlp` | Export structured log events |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector URL |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers |

Pass via `ClaudeAgentOptions.env` (Python: merged with inherited env; TypeScript: replaces inherited env, so spread `process.env`).

### Cost Tracking

Read from `ResultMessage`: `total_cost_usd`, `usage` (input/output/cache tokens). For turn-by-turn cost, read from individual `AssistantMessage` objects if cost tracking fields are present.

### Structured Outputs

Use `system_prompt` to instruct Claude to return JSON, combined with result parsing. Or use custom tools that return `structuredContent` (TypeScript in-process MCP servers only).

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — What the SDK is, capabilities, comparison with Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step first agent, permission modes overview, troubleshooting
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How turns, messages, and context accumulate; handling results
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Skills, commands, memory, plugins accessible from the SDK
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Reading token usage and cost from the response stream
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — Defining tools with in-process MCP servers, error handling, images/resources, structured data
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and revert file changes the agent made
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Callback hooks for intercepting agent events, examples, troubleshooting
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Docker, cloud, and CI/CD deployment patterns
- [MCP](references/claude-code-agent-sdk-mcp.md) — External MCP server configuration: stdio, HTTP/SSE, auth, tool search
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from older SDK versions
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Append, prepend, or replace the system prompt
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, and log events
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, evaluation order
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading Claude Code plugins from the SDK
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Full Python API: `query()`, `ClaudeAgentOptions`, `ClaudeSDKClient`, all types
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Security best practices for production agents
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; session storage; cross-host resumption
- [Skills](references/claude-code-agent-sdk-skills.md) — Loading and using Claude Code skills from the SDK
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Using custom commands from the SDK
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Real-time token streaming with `includePartialMessages`
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Choosing between streaming and single-turn input modes
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — Getting JSON-structured responses from agents
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Defining and invoking subagents, parallelism, context isolation
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — How Claude tracks and updates task lists during agent runs
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Load tools on demand for large tool sets
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Full TypeScript API: `query()`, `Options`, all types and interfaces
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Notes on the removed experimental V2 session API
- [User Input](references/claude-code-agent-sdk-user-input.md) — Interactive approval prompts and `AskUserQuestion` handling
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — Custom `SessionStore` adapters for cross-host session persistence

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
