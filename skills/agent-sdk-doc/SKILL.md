---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents with Python and TypeScript, including the agent loop, permissions, hooks, sessions, subagents, MCP integration, custom tools, streaming, structured outputs, hosting, secure deployment, observability, cost tracking, and full API references for both SDKs.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

The Claude Agent SDK lets you embed Claude Code's autonomous agent loop in Python or TypeScript applications. Claude handles tool execution, context management, and retries — you just supply a prompt and consume the stream.

### Installation

| Language | Package | Install command |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

The TypeScript SDK bundles a native Claude Code binary; no separate Claude Code install is needed.

### Authentication

| Method | How |
| :--- | :--- |
| Anthropic API (default) | `export ANTHROPIC_API_KEY=your-api-key` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Minimal example

```python
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
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  if ("result" in message) console.log(message.result);
}
```

### Built-in tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script; react to each output line |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions |
| `Agent` | Spawn a subagent to handle a focused subtask |
| `ToolSearch` | Dynamically load tool definitions on demand |
| `TodoWrite` | Track tasks within a session |

### Permission modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | No auto-approvals; unmatched tools call `canUseTool` | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and common filesystem commands | Trusted dev workflows |
| `dontAsk` | Denies anything not in `allowedTools`; never calls `canUseTool` | Locked-down headless agents |
| `plan` | No tool execution; Claude plans without making changes | Review-before-run |
| `bypassPermissions` | All tools run without prompts | Sandboxed CI, fully trusted environments |
| `auto` (TypeScript only) | Model classifier approves/denies each call | Autonomous agents with safety guardrails |

Permission evaluation order: Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

### `ClaudeAgentOptions` key fields

| Field (Python / TypeScript) | Type | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `string[]` | Pre-approve these tools (auto-allowed, no prompt) |
| `disallowed_tools` / `disallowedTools` | `string[]` | Always deny these tools |
| `permission_mode` / `permissionMode` | `PermissionMode` | Global permission mode (see table above) |
| `system_prompt` / `systemPrompt` | `string` | Custom system prompt prepended to all sessions |
| `max_turns` / `maxTurns` | `number` | Cap tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | `number` | Stop when spend exceeds this amount |
| `effort` | `"low" \| "medium" \| "high" \| "xhigh" \| "max"` | Reasoning depth (TypeScript default: `"high"`) |
| `model` | `string` | Model ID or alias (`"sonnet"`, `"opus"`, `"haiku"`) |
| `cwd` | `string` | Working directory for tool execution |
| `resume` | `string` | Resume a specific past session by ID |
| `fork_session` / `forkSession` | `boolean` | Fork a session to explore an alternative |
| `continue_conversation` / `continue` | `boolean` | Resume the most recent session in the current directory |
| `mcp_servers` / `mcpServers` | `object` | MCP server configurations |
| `agents` | `object` | Subagent definitions |
| `hooks` | `object` | Hook callbacks keyed by event name |
| `setting_sources` / `settingSources` | `string[]` | Which config sources to load (`"project"`, `"user"`, etc.) |

### Message types

| Type (Python class / TS `type` string) | When emitted | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` / `"system"` | Session start (subtype `"init"`), after compaction | `session_id`, `mcp_servers` |
| `AssistantMessage` / `"assistant"` | After each Claude response | `content` (text + tool call blocks) |
| `UserMessage` / `"user"` | After each tool execution | Tool result content |
| `ResultMessage` / `"result"` | End of agent loop | `subtype`, `result`, `total_cost_usd`, `session_id` |
| `StreamEvent` / `"stream_event"` | When `includePartialMessages` enabled | Raw streaming events |

### Result subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled request | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

### Session management

| Approach | Python | TypeScript | Use when |
| :--- | :--- | :--- | :--- |
| One-shot | `query()` | `query()` | Single task, no follow-up |
| Multi-turn (auto) | `ClaudeSDKClient` | `continue: true` | Chained prompts in one process |
| Resume by ID | `resume=session_id` | `resume: sessionId` | Return to a specific past session |
| Fork | `fork_session=True` + `resume` | `forkSession: true` + `resume` | Try alternative without losing original |
| Stateless | N/A | `persistSession: false` | No session written to disk |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `cwd` must match when resuming.

### Hooks

Hooks are callback functions that fire at agent lifecycle events. Register them in `options.hooks`.

| Hook event | Python | TypeScript | What triggers it |
| :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes (can block/modify) |
| `PostToolUse` | Yes | Yes | After a tool returns |
| `PostToolUseFailure` | Yes | Yes | Tool execution failure |
| `PostToolBatch` | No | Yes | Full batch of tool calls resolves |
| `UserPromptSubmit` | Yes | Yes | User prompt submission |
| `Stop` | Yes | Yes | Agent execution stops |
| `SubagentStart` | Yes | Yes | Subagent initializes |
| `SubagentStop` | Yes | Yes | Subagent completes |
| `PreCompact` | Yes | Yes | Context compaction about to occur |
| `PermissionRequest` | Yes | Yes | Permission dialog would show |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |

Hook callback signature (Python): `async def my_hook(input_data, tool_use_id, context) -> dict`

Hook return values:
- `{}` — allow, no changes
- `{"hookSpecificOutput": {"hookEventName": "...", "permissionDecision": "deny", "permissionDecisionReason": "..."}}` — block
- `{"hookSpecificOutput": {"hookEventName": "...", "permissionDecision": "allow", "updatedInput": {...}}}` — modify input
- `{"systemMessage": "...", "hookSpecificOutput": {...}}` — inject context + block/allow
- `{"async_": True, "asyncTimeout": 30000}` (Python) / `{"async": true}` (TypeScript) — fire and forget

### Subagents

Subagents are separate agent instances for isolated subtasks. Must include `"Agent"` in `allowedTools`.

```python
from claude_agent_sdk import AgentDefinition

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Use for code quality and security reviews.",
            prompt="You are a code review specialist...",
            tools=["Read", "Grep", "Glob"],
            model="sonnet",
        )
    },
)
```

`AgentDefinition` fields: `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model`, `skills`, `memory`, `mcpServers`, `maxTurns`, `background`, `effort`, `permissionMode`.

Subagent common tool combinations:

| Use case | Tools |
| :--- | :--- |
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Test execution | `Bash`, `Read`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Grep`, `Glob` |
| Full access | Omit `tools` field (inherits all) |

### MCP in the SDK

```python
options = ClaudeAgentOptions(
    mcp_servers={
        "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {"GITHUB_TOKEN": os.environ["GITHUB_TOKEN"]},
        }
    },
    allowed_tools=["mcp__github__list_issues"],
)
```

MCP tool naming: `mcp__<server-name>__<tool-name>`. Wildcards (`mcp__github__*`) allow all tools from a server.

Transport types: `stdio` (local process), `http` (non-streaming), `sse` (streaming). Set `type` field for HTTP/SSE servers.

### Python SDK: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New each time | Reuses same session |
| Interrupts | Not supported | Supported |
| Use case | One-off tasks | Continuous conversations |
| Usage | `async for msg in query(...)` | `async with ClaudeSDKClient(...) as client: await client.query(...); async for msg in client.receive_response()` |

### TypeScript SDK extras

- `startup()` — pre-warm the CLI subprocess before a prompt is ready (reduces first-call latency)
- V2 preview — `createSession()` with `send()` / `stream()` patterns (unstable, see `typescript-v2-preview` ref)

### Effort levels

| Level | Reasoning depth | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal | File lookups, listing directories |
| `"medium"` | Balanced | Routine edits, standard tasks |
| `"high"` | Thorough (TS default) | Refactors, debugging |
| `"xhigh"` | Extended | Coding/agentic tasks; recommended on Opus 4.7 |
| `"max"` | Maximum | Multi-step problems requiring deep analysis |

### Context management tips

- Use subagents for long subtasks — they run in a fresh context; only the final result returns to the parent
- Set `allowedTools` to the minimum needed — each tool definition consumes context space
- Use MCP tool search to load tools on demand instead of all at once
- Add summarization instructions to `CLAUDE.md` to preserve key info across compaction

### Hosting patterns

| Pattern | Container lifecycle | Best for |
| :--- | :--- | :--- |
| Ephemeral | Create per task, destroy on complete | One-off tasks (bug fixes, translations) |
| Long-running | Persistent, possibly multiple agents | Email agents, chat bots, site builders |
| Hybrid | Ephemeral + session resumption | Intermittent multi-session tasks |
| Single container | One container, many agent processes | Closely collaborating agents |

Minimum container spec: 1 GiB RAM, 5 GiB disk, 1 CPU. Requires outbound HTTPS to `api.anthropic.com`.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK Overview](references/claude-code-agent-sdk-overview.md) — capabilities, built-in tools, hooks, subagents, MCP, permissions, sessions, Claude Code features comparison, changelog
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step setup, first agent, running it, customization options, key concepts, troubleshooting
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — turns, messages, tool execution, parallel tools, control options, context window, compaction, sessions, result handling
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — complete API reference: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, hook types
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — complete API reference: `query()`, `startup()`, `tool()`, `Options`, all message types, hook types, V2 preview
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — new `createSession()`, `send()`, `stream()` API (unstable preview)
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient` vs `continue: true`; cross-host resumption; session utilities
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes detail, dynamic mode changes, `acceptEdits` auto-approved ops
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matchers, callback inputs/outputs, async hooks, examples, common issues
- [Subagents](references/claude-code-agent-sdk-subagents.md) — programmatic vs filesystem definitions, `AgentDefinition` config, invocation, detecting subagents, resuming subagents, tool restrictions
- [MCP Integration](references/claude-code-agent-sdk-mcp.md) — stdio/HTTP/SSE transports, tool naming, `allowedTools`, authentication, tool search, error handling
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — defining in-process MCP tools with `tool()`, SDK MCP server setup
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — loading CLAUDE.md, skills, slash commands, plugins, and hooks from filesystem via `settingSources`
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — enabling `includePartialMessages`, handling `StreamEvent` for real-time text/tool deltas
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use streaming input (`AsyncGenerator`) vs single string prompt
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — enforcing JSON schema responses with `outputSchema`
- [User Input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback for interactive approval, `AskUserQuestion` tool, handling clarifying questions
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage` fields, per-turn cost breakdown
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, telemetry integration, structured tracing
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool for task tracking within a session
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — deferring MCP tool definitions to reduce context usage, `ToolSearch` tool
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshotting and reverting file changes made by the agent
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `systemPrompt`, `appendSystemPrompt`, loading CLAUDE.md
- [Skills](references/claude-code-agent-sdk-skills.md) — loading plugin skills into SDK agents via `settingSources`
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — sending `/compact`, `/clear`, and other slash commands as prompts in SDK sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — using Claude Code plugins with the SDK
- [Hosting](references/claude-code-agent-sdk-hosting.md) — deployment patterns (ephemeral, long-running, hybrid), container requirements, sandbox providers, FAQ
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies (Docker, gVisor, Firecracker)
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from the old Claude Code SDK to the Claude Agent SDK

## Sources

- Agent SDK Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent Loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- MCP Integration: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Custom Tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Claude Code Features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Streaming Output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Cost Tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- File Checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Modifying System Prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration Guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
