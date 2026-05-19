---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — overview, quickstart, agent loop, message types, sessions, permissions, hooks, subagents, MCP servers, custom tools, streaming, structured outputs, observability, hosting, secure deployment, and the Python and TypeScript API references.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### Installation

| Language | Package | Command |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

Set `ANTHROPIC_API_KEY` before running. For cloud providers set `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, or `CLAUDE_CODE_USE_FOUNDRY=1`.

> Migrating from the old Claude Code SDK? Old packages: `@anthropic-ai/claude-code` (TS) and `claude-code-sdk` (Python). Replace with the packages above; the API is unchanged.

### Core API — `query()`

Both SDKs expose a `query()` function that returns an async iterator of messages.

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Bash"],
        permission_mode="acceptEdits",
    ),
):
    ...
```

**TypeScript:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"], permissionMode: "acceptEdits" }
})) { ... }
```

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script and react to each output line |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions |
| `Agent` | Spawn a subagent (required in `allowedTools` to use subagents) |
| `ToolSearch` | Dynamically load MCP tools on demand |

### Agent Loop — Message Types

As the loop runs, the SDK yields a stream of typed messages:

| Type | Python class | TS `type` field | When it fires |
| :--- | :--- | :--- | :--- |
| System | `SystemMessage` | `"system"` | Session start (`subtype: "init"`) and compaction boundary |
| Assistant | `AssistantMessage` | `"assistant"` | After each Claude response (text and tool call blocks) |
| User | `UserMessage` | `"user"` | After each tool execution with the result |
| Stream event | `StreamEvent` | `"stream_event"` | Partial token deltas (only when `includePartialMessages: true`) |
| Result | `ResultMessage` | `"result"` | End of agent loop — final text, cost, usage, session ID |

**Check types:**
- Python: `isinstance(message, ResultMessage)`
- TypeScript: `message.type === "result"` (content blocks live at `message.message.content`, not `message.content`)

### Result Subtypes

| Subtype | Meaning | `result` field present? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Key Options (`ClaudeAgentOptions` / `Options`)

| Option (Python / TS) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Auto-approve these tools (no prompting) |
| `disallowed_tools` / `disallowedTools` | Always block these tools |
| `permission_mode` / `permissionMode` | Global permission strategy (see below) |
| `system_prompt` / `systemPrompt` | Replace default system prompt |
| `max_turns` / `maxTurns` | Cap tool-use turns; returns `error_max_turns` |
| `max_budget_usd` / `maxBudgetUsd` | Cap spend; returns `error_max_budget_usd` |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Pin a specific model ID |
| `cwd` | Working directory for the agent |
| `mcp_servers` / `mcpServers` | Connect MCP servers |
| `hooks` | Register lifecycle hook callbacks |
| `agents` | Define named subagents |
| `resume` | Resume a specific session by ID |
| `continue_conversation` / `continue` | Resume the most recent session |
| `fork_session` / `forkSession` | Fork from `resume` session into a new one |
| `setting_sources` / `settingSources` | Which config sources to load (`"user"`, `"project"`, `"local"`) |
| `include_partial_messages` / `includePartialMessages` | Enable streaming token deltas |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Unmatched tools trigger `canUseTool` callback | Interactive apps with custom approval |
| `acceptEdits` | Auto-approves file edits and common FS commands (`mkdir`, `touch`, `mv`, `cp`, etc.) | Trusted dev workflows |
| `dontAsk` | Anything not in `allowedTools` is denied; never calls `canUseTool` | Locked-down headless agents |
| `plan` | Read-only tools only; Claude explores and produces a plan | Code review without modifications |
| `auto` (TS only) | Model classifier approves or denies each call | Autonomous agents with safety guardrails |
| `bypassPermissions` | All tools run without prompts; deny rules still apply | CI/CD, isolated sandboxes only |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

**Warning:** `allowed_tools` does not constrain `bypassPermissions`. Use `disallowed_tools` to block specific tools in bypass mode.

### Sessions

| Pattern | How |
| :--- | :--- |
| New session | Default `query()` call |
| Continue most recent (Python) | `ClaudeSDKClient` auto-tracks, or `continue_conversation=True` |
| Continue most recent (TS) | `continue: true` in options |
| Resume specific session | `resume=session_id` in options; capture ID from `ResultMessage.session_id` |
| Fork session | `resume=session_id` + `fork_session=True` — creates new session, original unchanged |
| Stateless (TS only) | `persistSession: false` — session in memory only |

Sessions stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `cwd` must match when resuming.

**Python `ClaudeSDKClient`** (preferred for multi-turn):
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("First prompt")
    async for message in client.receive_response(): ...
    await client.query("Follow-up")       # automatically continues same session
    async for message in client.receive_response(): ...
```

### Hooks

Hooks are callback functions registered in `options.hooks`. They fire at specific lifecycle events:

| Event | Python | TS | When it fires | Common use |
| :--- | :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before tool executes | Block dangerous commands, validate input |
| `PostToolUse` | Yes | Yes | After tool returns | Audit, log, inject context |
| `PostToolUseFailure` | Yes | Yes | Tool execution failed | Log errors |
| `PostToolBatch` | No | Yes | Full batch resolves | Inject conventions once per batch |
| `UserPromptSubmit` | Yes | Yes | Prompt submitted | Add context to prompts |
| `Stop` | Yes | Yes | Agent finishes | Save session state |
| `SubagentStart` | Yes | Yes | Subagent spawns | Track parallel tasks |
| `SubagentStop` | Yes | Yes | Subagent completes | Aggregate results |
| `PreCompact` | Yes | Yes | Before compaction | Archive full transcript |
| `PermissionRequest` | Yes | Yes | Permission dialog would show | Custom permission handling |
| `Notification` | Yes | Yes | Agent status messages | Forward to Slack/PagerDuty |
| `SessionStart` | No | Yes | Session init | Initialize logging |
| `SessionEnd` | No | Yes | Session ends | Cleanup resources |

**Hook callback signature (Python):** `async def my_hook(input_data, tool_use_id, context) -> dict`

**Hook callback signature (TypeScript):** `const myHook: HookCallback = async (input, toolUseID, { signal }) => {...}`

**Hook matcher syntax:** `matcher` is a regex matched against the tool name. Use `"Write|Edit"` for multiple tools; `"^mcp__"` for all MCP tools. Omit matcher to match all events of that type.

**Return values:**
- `{}` — allow without changes
- `{"hookSpecificOutput": {"hookEventName": ..., "permissionDecision": "deny", "permissionDecisionReason": "..."}}` — block tool
- `{"hookSpecificOutput": {"hookEventName": ..., "permissionDecision": "allow", "updatedInput": {...}}}` — allow with modified input
- `{"async_": True, "asyncTimeout": 30000}` (Python) / `{"async": true, "asyncTimeout": 30000}` (TS) — fire-and-forget

**Priority when multiple hooks conflict:** deny > defer > ask > allow.

### Subagents

Define named subagents in `agents` option; Claude invokes them via the `Agent` tool:

```python
agents={
    "code-reviewer": AgentDefinition(
        description="Expert code reviewer. Use for quality and security reviews.",
        prompt="You are a code review specialist...",
        tools=["Read", "Glob", "Grep"],
    )
}
```

- `Agent` must be in `allowedTools` for subagent invocation to work
- Each subagent runs in its own fresh conversation (no parent message history)
- Only the subagent's final message returns to the parent
- Use `SubagentStart`/`SubagentStop` hooks to track parallel task results
- `effort` can be set per subagent via `AgentDefinition`

**Three ways to create subagents:** programmatically (via `agents` option), filesystem-based (`.claude/agents/*.md`), or built-in general-purpose agent.

### MCP Servers

```python
mcp_servers={
    "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},  # stdio
    "my-api": {"type": "http", "url": "https://api.example.com/mcp"},      # HTTP
}
allowed_tools=["mcp__playwright__*"]  # wildcard for all tools from a server
```

MCP tool naming: `mcp__<server-name>__<tool-name>`. Custom (in-process) MCP servers via `createSdkMcpServer` / `create_sdk_mcp_server`.

**Tool search** defers MCP schema loading until needed — saves context on large tool sets. Falls back to upfront loading on Vertex AI or non-first-party `ANTHROPIC_BASE_URL`.

### Custom Tools

```python
@tool(name="get_weather", description="Get current temperature", schema={"city": str})
async def get_weather(city: str) -> CallToolResult:
    return {"content": [{"type": "text", "text": f"72°F in {city}"}]}

server = create_sdk_mcp_server([get_weather])
options = ClaudeAgentOptions(mcp_servers={"weather": server})
```

Set `readOnlyHint: true` in tool annotations to allow parallel execution.

### Streaming Output

Enable with `include_partial_messages=True` / `includePartialMessages: true`. The SDK then yields `StreamEvent` messages. Filter for `content_block_delta` events where `delta.type == "text_delta"` to get text chunks.

### Structured Outputs

Pass a JSON Schema (or Zod/Pydantic model) as `output_schema` / `outputSchema`. The SDK validates the response and re-prompts on mismatch (up to configured retries). Failed validation returns `error_max_structured_output_retries`.

### Observability (OpenTelemetry)

Set environment variables (in shell or `options.env`):

| Variable | Purpose |
| :--- | :--- |
| `CLAUDE_CODE_ENABLE_TELEMETRY=1` | Enable telemetry (required) |
| `OTEL_METRICS_EXPORTER` | Enable metrics (token/cost counters) |
| `OTEL_LOGS_EXPORTER` | Enable structured log events |
| `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Enable traces (beta) |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Your OTLP collector URL |

**Note (TypeScript):** `options.env` replaces the inherited environment; include `...process.env` to keep existing vars.

### Effort Levels

| Level | Good for |
| :--- | :--- |
| `"low"` | File lookups, directory listings |
| `"medium"` | Routine edits, standard tasks |
| `"high"` | Refactors, debugging (TS default) |
| `"xhigh"` | Coding/agentic tasks; recommended on Opus 4.7 |
| `"max"` | Multi-step problems requiring deep analysis |

Python SDK leaves effort unset if not specified (defers to model default).

### Context Window Management

- Content accumulates each turn: system prompt, tool defs, history, tool I/O
- Prompt caching applies to static content (system prompt, CLAUDE.md, tool defs)
- Automatic compaction occurs near the context limit; fires `compact_boundary` event
- Customize compaction: add summarization instructions to CLAUDE.md; use `PreCompact` hook; send `/compact` as prompt
- Subagents keep parent context lean — only their final summary returns to parent

### Hosting & Production

- Each SDK instance: 1 GiB RAM, 5 GiB disk, 1 CPU (recommended minimum)
- Requires outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production (Modal, E2B, Fly, Vercel, etc.)
- TypeScript: `startup()` pre-warms the CLI subprocess to reduce first-query latency

### Python `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New by default | Reuses same session |
| Multi-turn | Manual via `resume`/`continue` | Automatic |
| Interrupts | Not supported | Supported |
| Use case | One-off tasks | Continuous conversations |

### TypeScript `startup()` — Pre-warming

```typescript
import { startup } from "@anthropic-ai/claude-agent-sdk";
const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) { ... }
```

### Setting Sources

Control which filesystem configs are loaded:

| Source | What it loads |
| :--- | :--- |
| `"user"` | `~/.claude/CLAUDE.md`, user settings, user MCP |
| `"project"` | `CLAUDE.md`, `.claude/settings.json`, `.mcp.json`, `.claude/skills/`, `.claude/agents/` |
| `"local"` | `.claude/settings.local.json` |

Default `query()` loads all sources. Set `setting_sources` / `settingSources` to restrict.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — capabilities, built-in tools, hooks, subagents, MCP, permissions, sessions, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to building a bug-fixing agent; key concepts, permission modes, troubleshooting
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — loop lifecycle, message types, tool execution, parallel tools, turns and budget, effort, permission mode, context window, compaction, sessions, result handling, hooks summary
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types and classes, message types, hook types
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — `query()`, `startup()`, `tool()`, `Options`, all types and interfaces, message types, hook types
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — experimental API notes and migration status
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; capturing session IDs; cross-host resumption; session management utilities
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, permission modes, dynamic mode changes
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, configure hooks, matchers, callback inputs/outputs, async hooks, examples (block tools, modify inputs, auto-approve, subagent tracking, HTTP webhooks, Slack notifications), troubleshooting
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — programmatic and filesystem-based definitions, `AgentDefinition`, context isolation, parallelization, what subagents inherit
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — transport types (stdio, HTTP/SSE), authentication, tool search, error handling
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool`, `createSdkMcpServer`, schemas, error handling, tool annotations, returning images and resources, structured data
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — enabling partial messages, `StreamEvent` types, filtering text deltas
- [Streaming vs. single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — input modes, when to use each
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, retry behavior, error handling
- [User input and approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — metrics, logs, traces (beta), OTLP configuration, per-call vs. process env
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — reading cost from `ResultMessage`, token usage fields
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — agent task management with `TaskCreate`/`TaskUpdate`
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred MCP tool loading, configuration matrix
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `system_prompt`, `append_system_prompt`, CLAUDE.md integration
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — skills, slash commands, memory, plugins via `settingSources`
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — sending slash commands (e.g., `/compact`) as SDK prompt strings
- [Skills](references/claude-code-agent-sdk-skills.md) — loading project skills via setting sources
- [Plugins](references/claude-code-agent-sdk-plugins.md) — programmatic plugin loading via `plugins` option
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — system requirements, container-based sandboxing, production deployment patterns, sandbox provider options
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies (Docker, gVisor, Firecracker)
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — from `@anthropic-ai/claude-code` / `claude-code-sdk` to the new packages

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs. single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input and approvals: https://code.claude.com/docs/en/agent-sdk/user-input.md
