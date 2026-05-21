---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — a Python and TypeScript library for building production AI agents that autonomously use tools, manage sessions, and run as part of your application.

## Quick Reference

### Installation

| SDK | Command |
| :--- | :--- |
| Python | `pip install claude-agent-sdk` |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` |

The TypeScript SDK bundles a native Claude Code binary for the host platform — no separate Claude Code install needed.

### Core API: `query()`

The primary entry point. Returns an async iterator (Python) / async generator (TypeScript) that streams messages as the agent works.

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Fix the bug in auth.py",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Bash"],
        permission_mode="acceptEdits",
    ),
):
    print(message)
```

**TypeScript:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"], permissionMode: "acceptEdits" }
})) {
  console.log(message);
}
```

### Authentication

| Provider | Environment Variable(s) |
| :--- | :--- |
| Anthropic API (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Built-in Tools

| Category | Tools | What They Do |
| :--- | :--- | :--- |
| File ops | `Read`, `Write`, `Edit` | Read, create, and modify files |
| Search | `Glob`, `Grep` | Find files by pattern, search content by regex |
| Execution | `Bash` | Run shell commands, scripts, git operations |
| Web | `WebSearch`, `WebFetch` | Search the web, fetch and parse pages |
| Discovery | `ToolSearch` | Load MCP tools on demand without preloading all |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate` | Spawn subagents, invoke skills, get user input, track tasks |
| Monitoring | `Monitor` | Watch a background script and react to each output line |

### Permission Modes

| Mode | Behavior | Use Case |
| :--- | :--- | :--- |
| `default` | Unmatched tools trigger `canUseTool` callback | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) | Trusted dev workflows |
| `plan` | Read-only tools only; Claude explores without editing | Safe planning/review |
| `dontAsk` | Deny instead of prompting for anything not pre-approved | Locked-down headless agents |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call | Autonomous agents with safety guardrails |
| `bypassPermissions` | All tools run without prompts (cannot be used as root) | CI/sandboxed environments only |

### Permission Evaluation Order

1. **Hooks** — can deny or pass on
2. **Deny rules** (`disallowed_tools`) — blocked even in `bypassPermissions`
3. **Permission mode** — `bypassPermissions` approves here
4. **Allow rules** (`allowed_tools`) — pre-approves listed tools
5. **`canUseTool` callback** — skipped in `dontAsk` mode

### Message Types

| Type | Python class | TS `type` field | When emitted |
| :--- | :--- | :--- | :--- |
| Session init | `SystemMessage` (subtype `"init"`) | `"system"` + `subtype:"init"` | First message; contains `session_id` |
| Claude response | `AssistantMessage` | `"assistant"` | After each Claude response (tool calls + text) |
| Tool results | `UserMessage` | `"user"` | After each tool execution batch |
| Streaming events | `StreamEvent` | `"stream_event"` | Only when `includePartialMessages` is enabled |
| Final result | `ResultMessage` | `"result"` | End of loop; contains cost, usage, session ID |
| Compaction | `SystemMessage` (subtype `"compact_boundary"`) | `SDKCompactBoundaryMessage` (TS) | After auto-compaction |

### Result Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled request | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All result subtypes include `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Key `ClaudeAgentOptions` / `Options` Fields

| Python field | TypeScript field | Description |
| :--- | :--- | :--- |
| `allowed_tools` | `allowedTools` | Tools to auto-approve |
| `disallowed_tools` | `disallowedTools` | Tools to block entirely (bare name removes from context) |
| `permission_mode` | `permissionMode` | Global permission behavior |
| `system_prompt` | `systemPrompt` | Custom system prompt for the agent |
| `model` | `model` | Model override (e.g. `"claude-sonnet-4-6"`) |
| `max_turns` | `maxTurns` | Cap on tool-use turns (no limit by default) |
| `max_budget_usd` | `maxBudgetUsd` | Cost cap before stopping (no limit by default) |
| `effort` | `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `mcp_servers` | `mcpServers` | External MCP server connections |
| `agents` | `agents` | Named subagent definitions (`AgentDefinition`) |
| `hooks` | `hooks` | Lifecycle hook callbacks |
| `resume` | `resume` | Session ID to resume |
| `fork_session` | `forkSession` | Create a new session branched from `resume` |
| `continue_conversation` | `continue` | Resume the most recent session in cwd |
| `setting_sources` | `settingSources` | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `cwd` | `cwd` | Working directory for the agent |
| `include_partial_messages` | `includePartialMessages` | Enable token-level streaming via `StreamEvent` |
| `output_format` | `outputFormat` | Structured output schema (JSON Schema / Zod / Pydantic) |

### Sessions

| Pattern | Python | TypeScript | When to Use |
| :--- | :--- | :--- | :--- |
| One-shot | `query()` | `query()` | Single task, no follow-up |
| Multi-turn (automatic) | `ClaudeSDKClient` | `continue: true` | Continuous conversation in one process |
| Resume specific session | `resume=session_id` | `resume: sessionId` | Return to a past session by ID |
| Fork | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Branch from an existing session |
| Stateless (no disk) | N/A (always persists) | `persistSession: false` | Ephemeral in-memory session |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `<encoded-cwd>` encodes the absolute path with non-alphanumeric characters replaced by `-`. Resume fails silently if `cwd` doesn't match.

### Hooks

| Event | Python | TypeScript | When It Fires |
| :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes — can block, modify input, or allow |
| `PostToolUse` | Yes | Yes | After a tool returns — can append context or replace output |
| `PostToolUseFailure` | Yes | Yes | After a tool execution failure |
| `PostToolBatch` | No | Yes | After a full batch of tool calls resolves |
| `UserPromptSubmit` | Yes | Yes | When a prompt is submitted — can inject context |
| `Stop` | Yes | Yes | When the agent finishes |
| `SubagentStart` | Yes | Yes | When a subagent spawns |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before context compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would appear |
| `Notification` | Yes | Yes | Agent status messages (`permission_prompt`, `idle_prompt`, etc.) |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |

**Hook callback output fields:**
- `hookSpecificOutput.permissionDecision`: `"allow"`, `"deny"`, `"ask"`, or `"defer"`
- `hookSpecificOutput.permissionDecisionReason`: explains the decision to Claude
- `hookSpecificOutput.updatedInput`: modified tool input (must pair with `"allow"` or `"ask"`)
- `hookSpecificOutput.additionalContext` (`PostToolUse`): append to tool result
- `hookSpecificOutput.updatedToolOutput` (`PostToolUse`): replace tool result entirely
- `systemMessage`: message shown to the user (not to Claude)
- `continue` / `continue_` (Python): whether to keep running
- `async: true` / `async_: true` (Python): return immediately without blocking the agent

Multiple hooks registered for the same event run in parallel. Most restrictive wins: any `deny` blocks the tool regardless of other hooks.

### Subagents (SDK)

Define programmatic subagents via the `agents` option. Include `Agent` in `allowedTools` since Claude invokes subagents through the Agent tool.

**`AgentDefinition` fields:**

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When Claude should use this subagent |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Allowed tools (inherits all if omitted) |
| `disallowedTools` | No | Tools to block |
| `model` | No | Model alias (`"sonnet"`, `"opus"`, `"haiku"`) or full model ID |
| `skills` | No | Skill names to preload at startup |
| `memory` | No | Persistent memory scope |
| `mcpServers` | No | MCP servers for this subagent |
| `maxTurns` | No | Turn cap for this subagent |
| `background` | No | Run non-blocking in parallel |
| `effort` | No | Reasoning effort level |
| `permissionMode` | No | Permission mode override |

Subagents receive their own system prompt, project CLAUDE.md, and tool definitions, but not the parent's conversation history. Only the final response returns to the parent. Subagents cannot spawn further subagents.

### MCP in the SDK

```python
# Python
options = ClaudeAgentOptions(
    mcp_servers={
        "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},
        "remote-api": {"type": "http", "url": "https://api.example.com/mcp"},
    },
    allowed_tools=["mcp__playwright__*", "mcp__remote-api__query"],
)
```

MCP tool names follow the pattern `mcp__<server-name>__<tool-name>`. Use wildcards (`mcp__<server>__*`) to allow all tools from a server. By default, MCP tool schemas are deferred (Tool Search) to save context. Disable deferral per-server with `"alwaysLoad": true` in the server config.

### Custom Tools

Define tools with `@tool` (Python) or `tool()` (TypeScript), then wrap in `create_sdk_mcp_server` / `createSdkMcpServer` and pass to `mcpServers`:

```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("lookup_user", "Look up a user by ID", {"user_id": str})
async def lookup_user(args):
    user = await db.get_user(args["user_id"])
    return {"content": [{"type": "text", "text": str(user)}]}

server = create_sdk_mcp_server([lookup_user])
options = ClaudeAgentOptions(
    mcp_servers={"my-tools": server},
    allowed_tools=["mcp__my-tools__lookup_user"],
)
```

Set `readOnlyHint: true` in annotations to enable parallel execution for a custom tool.

### Structured Outputs

Pass a schema to `output_format` / `outputFormat`. The SDK validates the result and re-prompts on mismatch (up to the retry limit). On failure, the result subtype is `error_max_structured_output_retries`.

```python
from pydantic import BaseModel

class CodeReview(BaseModel):
    issues: list[str]
    severity: str

options = ClaudeAgentOptions(output_format=CodeReview)
```

### Streaming Output

Enable token-level streaming with `include_partial_messages=True` / `includePartialMessages: true`. The SDK then yields `StreamEvent` messages containing raw API events. Check `event.type == "content_block_delta"` and `delta.type == "text_delta"` to extract text chunks.

### Cost Tracking

`ResultMessage` includes `total_cost_usd` (estimate) and `usage` (token counts). Per-step usage is available on `AssistantMessage`. When a session spans multiple `query()` calls, each call reports its own cost independently. `total_cost_usd` is a client-side estimate — use the Anthropic Console or Usage Cost API for authoritative billing.

### Context Management

| Strategy | Effect |
| :--- | :--- |
| Use subagents for subtasks | Each subagent starts with fresh context; only its summary returns to parent |
| Scope tools with `tools` on `AgentDefinition` | Fewer tool schemas = less context overhead |
| Enable Tool Search (default) | MCP tool schemas deferred until needed |
| Set lower `effort` for simple tasks | Fewer reasoning tokens per turn |
| Add summarization instructions to CLAUDE.md | Guides what compaction preserves |
| `PreCompact` hook | Archive full transcript before compaction |

Auto-compaction fires when the context window approaches its limit. Send `/compact` as a prompt string to trigger it manually. Persistent rules belong in CLAUDE.md (reinjected each request), not in the initial prompt (may be summarized away).

### Setting Sources

`settingSources` controls which filesystem-based settings load. Default loads `user`, `project`, and `local`. Pass `[]` to disable all filesystem settings (keeps managed policy and `~/.claude.json`).

| Source | Loads From |
| :--- | :--- |
| `"user"` | `~/.claude/` — user-level settings, skills, hooks |
| `"project"` | `./.claude/` in cwd — project settings, skills, hooks, CLAUDE.md |
| `"local"` | Local overrides |

### Observability

The SDK exports OpenTelemetry telemetry via the bundled CLI child process. Configure via environment variables:

| Signal | Enable With | What It Contains |
| :--- | :--- | :--- |
| Metrics | `OTEL_METRICS_EXPORTER` | Token/cost/session counters |
| Log events | `OTEL_LOGS_EXPORTER` | Per-prompt, API request, tool result records |
| Traces (beta) | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Spans per interaction, model request, tool call, hook |

Set variables in process environment (applies to all `query()` calls) or per-call in `options.env`. In TypeScript, `options.env` replaces the inherited environment; include `...process.env` to preserve it.

### Hosting Requirements

- Python 3.10+ (Python SDK) or Node.js 18+ (TypeScript SDK)
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production deployments

### Python SDK: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New each call (unless `resume`/`continue`) | Reuses same session automatically |
| Multi-turn | Manual via `resume` or `continue_conversation` | Automatic |
| Interrupts | Not supported | Supported |
| Use case | One-off tasks | Continuous conversations / chat UIs |

### TypeScript: `startup()` for Pre-warming

`startup()` spawns the CLI subprocess and completes the initialize handshake before a prompt is available. The returned `WarmQuery` accepts a prompt later, eliminating subprocess spawn latency on the first request.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities, comparison with Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to building and running a first agent
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, messages, tool execution, context window, compaction, result handling
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns, `ClaudeSDKClient`, cross-host session handling
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, dynamic mode changes
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matchers, callback inputs/outputs, examples
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, programmatic vs filesystem-based, context inheritance, resuming subagents
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — transport types, server config, tool search, auth, error handling
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool`, `createSdkMcpServer`, schemas, annotations, error handling
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive flows
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` handling
- [Streaming Input](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — streaming vs single-turn input modes
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, error handling
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, per-step usage, deduplication, prompt caching
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, hooks from filesystem
- [Agent Skills in the SDK](references/claude-code-agent-sdk-skills.md) — loading and invoking skills in SDK agents
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — using slash commands (including `/compact`) as SDK prompt strings
- [Todo Lists](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate` / `TaskUpdate` tool for task tracking
- [Scale to many tools with tool search](references/claude-code-agent-sdk-tool-search.md) — deferred MCP tool loading, configuration matrix
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — using plugins programmatically in SDK agents
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `systemPrompt`, `appendSystemPrompt`, CLAUDE.md interaction
- [Rewind file changes with checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert filesystem changes across sessions
- [Persist sessions to external storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` adapters for cross-host session sharing
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — production deployment patterns, sandbox providers, system requirements
- [Securely deploying AI agents](references/claude-code-agent-sdk-secure-deployment.md) — threat model, isolation, credential management, network controls
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — OTLP export, metrics, log events, traces, per-call configuration
- [Agent SDK reference - Python](references/claude-code-agent-sdk-python.md) — complete Python API reference: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types
- [Agent SDK reference - TypeScript](references/claude-code-agent-sdk-typescript.md) — complete TypeScript API reference: `query()`, `startup()`, `Options`, all types
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — migration guide from older SDK versions
- [TypeScript SDK V2 session API (removed)](references/claude-code-agent-sdk-typescript-v2-preview.md) — removed `createSession()` API; use `query()` with session options instead

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Rewind file changes with checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Agent SDK reference - Python: https://code.claude.com/docs/en/agent-sdk/python.md
- Securely deploying AI agents: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Agent Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming Input: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Lists: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Scale to many tools with tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Agent SDK reference - TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript SDK V2 session API (removed): https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Persist sessions to external storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
