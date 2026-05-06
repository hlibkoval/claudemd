---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — installing and using the Python and TypeScript SDKs, the query() function and agent loop, message types (SystemMessage, AssistantMessage, UserMessage, ResultMessage, StreamEvent), permission modes (default, acceptEdits, dontAsk, bypassPermissions, plan, auto), hooks (PreToolUse, PostToolUse, Stop, SubagentStop, PreCompact, Notification, etc.), sessions (resume, fork, continue, ClaudeSDKClient), subagents (AgentDefinition, context isolation, parallelization), MCP server integration (stdio, HTTP/SSE, tool naming mcp__server__tool), custom tools (tool decorator, createSdkMcpServer), structured outputs (JSON Schema, Zod, Pydantic), streaming output (includePartialMessages, StreamEvent, content_block_delta), cost tracking (total_cost_usd, modelUsage, cache tokens), and hosting/deployment patterns.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

### Installation

| Language | Package | Install |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

Set `ANTHROPIC_API_KEY` environment variable. Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), and Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Core Pattern

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        if isinstance(message, ResultMessage) and message.subtype == "success":
            print(message.result)

asyncio.run(main())
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read files in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script and react to each output line |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options |
| `ToolSearch` | Dynamically load tools on-demand instead of preloading all |
| `Agent` | Spawn subagents for focused subtasks |
| `Skill` | Invoke a skill |
| `TodoWrite` | Track tasks |

### Message Types

| Type | When emitted | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` | Session start (`subtype: "init"`) and after compaction (`"compact_boundary"`) | `session_id`, `data` |
| `AssistantMessage` | After each Claude response | `content` (text blocks + tool call blocks) |
| `UserMessage` | After each tool execution | tool result content |
| `StreamEvent` | Only when `includePartialMessages: true` | `event` (raw API streaming event) |
| `ResultMessage` | End of agent loop | `subtype`, `result`, `total_cost_usd`, `session_id` |

Python: check with `isinstance(message, ResultMessage)`. TypeScript: check `message.type === "result"`. In TypeScript, `AssistantMessage` content is at `message.message.content`.

### ResultMessage Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Unmatched tools call your `canUseTool` callback; no callback = deny |
| `acceptEdits` | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, `mv`, `cp`, etc.) |
| `dontAsk` | Anything not in `allowedTools` is denied; never calls `canUseTool` |
| `bypassPermissions` | All tools run without prompts (use only in isolated environments) |
| `plan` | Read-only tools only; Claude explores and produces a plan without editing files |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

Note: `bypassPermissions` is blocked when running as root on Unix. `disallowed_tools` denies even in `bypassPermissions` mode.

### ClaudeAgentOptions / Options Key Fields

| Field (Python / TypeScript) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Pre-approve listed tools; supports wildcards like `mcp__server__*` |
| `disallowed_tools` / `disallowedTools` | Block listed tools in all modes |
| `permission_mode` / `permissionMode` | See permission modes table above |
| `max_turns` / `maxTurns` | Max tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | Max cost before stopping |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Model ID, e.g. `"claude-sonnet-4-6"` |
| `system_prompt` / `systemPrompt` | Custom system prompt |
| `mcp_servers` / `mcpServers` | MCP server configs |
| `hooks` | SDK hook callbacks |
| `agents` | Subagent definitions |
| `setting_sources` / `settingSources` | Which config sources to load: `"project"`, `"user"`, `"local"` |
| `resume` | Session ID to resume |
| `fork_session` / `forkSession` | Fork the resumed session |
| `continue` (TS only) | Resume most recent session in cwd without an ID |
| `output_format` / `outputFormat` | Structured output schema |
| `include_partial_messages` / `includePartialMessages` | Enable streaming `StreamEvent` messages |

### Sessions

| Approach | Use when |
| :--- | :--- |
| Single `query()` call | One-shot task |
| `ClaudeSDKClient` (Python) | Multi-turn in one process; tracks session ID automatically |
| `continue: true` (TypeScript) | Resume most recent session in cwd |
| `resume: sessionId` | Resume a specific past session by ID |
| `forkSession: true` + `resume` | Branch from a session without modifying it |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. Capture session ID from `ResultMessage.session_id`. Utility functions: `list_sessions()`, `get_session_messages()`, `rename_session()`, `tag_session()` (both SDKs).

### Hooks

| Hook Event | Python | TypeScript | Fires when | Common use |
| :--- | :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes | Block dangerous commands, modify inputs |
| `PostToolUse` | Yes | Yes | After a tool returns | Audit, trigger side effects |
| `PostToolUseFailure` | Yes | Yes | After a tool fails | Log errors |
| `PostToolBatch` | No | Yes | Full batch resolves | Inject conventions once per batch |
| `UserPromptSubmit` | Yes | Yes | Prompt submitted | Inject additional context |
| `Stop` | Yes | Yes | Agent finishes | Save session state |
| `SubagentStart` | Yes | Yes | Subagent spawns | Track parallel tasks |
| `SubagentStop` | Yes | Yes | Subagent completes | Aggregate results |
| `PreCompact` | Yes | Yes | Before compaction | Archive full transcript |
| `PermissionRequest` | Yes | Yes | Permission dialog shown | Custom approval |
| `Notification` | Yes | Yes | Agent status message | Forward to Slack/PagerDuty |
| `SessionStart` | No | Yes | Session initializes | Init logging |
| `SessionEnd` | No | Yes | Session terminates | Cleanup |

Hook callback signature (Python): `async def my_hook(input_data, tool_use_id, context) -> dict`. Return `{}` to allow; return `hookSpecificOutput` with `permissionDecision: "deny"` to block. For `PostToolUse`, use `additionalContext` or `updatedToolOutput`. Multiple hooks run in parallel; deny beats all.

Configure via `options.hooks` dict keyed by event name, values are lists of matchers:
- Python: `HookMatcher(matcher="Edit|Write", hooks=[my_callback])`
- TypeScript: `{ matcher: "Edit|Write", hooks: [myCallback] }`

Matchers are regex patterns against tool name. MCP tools match `mcp__<server>__<action>`.

### Subagents (AgentDefinition)

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When Claude should use this subagent |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Restrict to listed tools; omit to inherit all |
| `disallowedTools` | No | Remove specific tools |
| `model` | No | Model alias: `"sonnet"`, `"opus"`, `"haiku"`, or full ID |
| `maxTurns` | No | Max turns for this subagent |
| `effort` | No | Reasoning effort override |
| `background` | No | Run as non-blocking background task |
| `permissionMode` | No | Permission mode for this subagent |

Subagents are invoked via the `Agent` tool — include `"Agent"` in `allowedTools`. Subagents cannot spawn their own subagents. Subagents receive their own system prompt and project CLAUDE.md, but not the parent conversation history.

Common tool sets:

| Pattern | Tools |
| :--- | :--- |
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Test execution | `Bash`, `Read`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Grep`, `Glob` |

### MCP Servers

MCP tool naming: `mcp__<server-name>__<tool-name>`. Use wildcards: `mcp__github__*`.

| Transport | Config key | When to use |
| :--- | :--- | :--- |
| stdio | `command`, `args`, `env` | Local process (e.g. `npx @modelcontextprotocol/server-github`) |
| HTTP | `type: "http"`, `url`, `headers` | Remote HTTP endpoint |
| SSE | `type: "sse"`, `url`, `headers` | Remote SSE endpoint |
| SDK MCP server | `createSdkMcpServer` / `create_sdk_mcp_server` | In-process custom tools |

Prefer `allowedTools: ["mcp__server__*"]` over `bypassPermissions` for MCP access. Check `status` field on servers in `system init` message for connection failures.

### Custom Tools

```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("get_temperature", "Get current temperature", {"latitude": float, "longitude": float})
async def get_temperature(args):
    # ... fetch data ...
    return {"content": [{"type": "text", "text": "72°F"}]}

server = create_sdk_mcp_server(name="weather", version="1.0.0", tools=[get_temperature])
# Pass server: options=ClaudeAgentOptions(mcp_servers={"weather": server}, allowed_tools=["mcp__weather__get_temperature"])
```

Tool annotations (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`) control parallel execution. Set `readOnlyHint: true` to allow parallel calls. Return `isError: true` (TypeScript) / `"is_error": True` (Python) to signal errors without stopping the loop.

### Structured Outputs

```typescript
options: {
  outputFormat: { type: "json_schema", schema: mySchema }
}
```

Access result via `message.structured_output` on a `ResultMessage`. Use Zod (`z.toJSONSchema()`) in TypeScript or Pydantic (`.model_json_schema()`) in Python for type-safe schemas. On failure, subtype is `error_max_structured_output_retries`.

### Streaming Output

Enable with `includePartialMessages: true` (TypeScript) / `include_partial_messages=True` (Python). Look for `StreamEvent` messages with `event.type === "content_block_delta"` and `event.delta.type === "text_delta"` for text chunks. Streaming is incompatible with extended thinking and structured outputs.

### Cost Tracking

- Per-query: read `message.total_cost_usd` from `ResultMessage`
- Per-model: read `message.modelUsage` (TS) / `message.model_usage` (Python) from `ResultMessage`
- Per-step: read `message.message.usage` (TS) / `message.usage` (Python) from `AssistantMessage`; deduplicate by message ID when using parallel tools
- Prompt caching: tracked via `cache_creation_input_tokens` and `cache_read_input_tokens`; set `ENABLE_PROMPT_CACHING_1H` for 1-hour TTL
- `total_cost_usd` is a client-side estimate, not authoritative billing

### Hosting Deployment Patterns

| Pattern | Description | Best for |
| :--- | :--- | :--- |
| Ephemeral sessions | New container per task, destroyed on complete | One-off tasks (bug fix, translation) |
| Long-running sessions | Persistent container, multiple agent processes | Email agents, chatbots, site builders |
| Hybrid sessions | Ephemeral containers hydrated with session history | Research agents, customer support |
| Single containers | Multiple SDK processes in one container | Simulations, closely collaborating agents |

System requirements per instance: 1 GiB RAM, 5 GiB disk, 1 CPU, outbound HTTPS to `api.anthropic.com`. No separate Claude Code install needed — SDK bundles the binary.

### Context Window Management

| Source | Impact |
| :--- | :--- |
| System prompt | Small fixed cost per request |
| CLAUDE.md files | Full content per request (prompt-cached) |
| Tool definitions | Each tool adds schema; use ToolSearch to load on demand |
| Conversation history | Grows each turn; compaction summarizes old history |
| MCP server tools | Each server adds all tool schemas |

Automatic compaction fires when context approaches its limit, emitting a `compact_boundary` message. Trigger manually with `/compact` as a prompt string. Use subagents for isolated subtasks to keep main context lean.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK Overview](references/claude-code-agent-sdk-overview.md) — intro, built-in tools, capabilities overview, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step first agent, key concepts, permission modes reference
- [How the Agent Loop Works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, compaction, result handling
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — complete Python API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, hook types
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — complete TypeScript API: `query()`, `Options`, all message types, hook types
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable V2 API with `createSession()` / `send` / `stream` pattern
- [Configure Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, `canUseTool` callback, dynamic mode changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matchers, callback inputs/outputs, async hooks, examples (block, modify input, notify Slack)
- [Work with Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, `ClaudeSDKClient`, cross-host resumption, session utilities
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition` config, context inheritance, parallel execution, resuming subagents
- [Connect to External Tools with MCP](references/claude-code-agent-sdk-mcp.md) — transport types, tool naming, allowedTools, authentication, error handling
- [Give Claude Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` decorator/function, `createSdkMcpServer`, annotations, error handling, images/resources
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — load MCP tools on demand to reduce context usage
- [Stream Responses in Real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent`, text/tool streaming, streaming UI
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to stream vs collect all messages
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod/Pydantic integration, error handling
- [Track Cost and Usage](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, per-step/per-model usage, cache tokens, multi-call accumulation
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `systemPrompt` option, CLAUDE.md integration
- [Claude Code Features in SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md, skills, slash commands, plugins
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — using project skills from SDK agents
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — sending `/compact` and other commands as prompts
- [User Input](references/claude-code-agent-sdk-user-input.md) — `AskUserQuestion` tool, `canUseTool` callback for interactive approvals
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, tracing, monitoring agent behavior
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool for task management
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — deployment patterns, container requirements, sandbox providers
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from Claude Code SDK to Claude Agent SDK

## Sources

- Agent SDK Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the Agent Loop Works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Configure Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Work with Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Connect to External Tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Give Claude Custom Tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Stream Responses in Real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Track Cost and Usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Modifying System Prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Claude Code Features in SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- File Checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration Guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
