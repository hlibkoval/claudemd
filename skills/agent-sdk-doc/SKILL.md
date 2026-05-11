---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — installation, query API, agent loop, sessions, hooks, permissions, subagents, MCP, custom tools, streaming, structured outputs, observability, hosting, and SDK references for Python and TypeScript.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly the Claude Code SDK). It covers building production AI agents in Python and TypeScript using the same tools, agent loop, and context management that power Claude Code.

## Quick Reference

### Installation

| Language | Package | Install |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

Set `ANTHROPIC_API_KEY` in your environment. Third-party providers: `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1`.

### Core API: `query()`

The primary entry point. Returns an async generator that streams messages as Claude works.

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

**Python also offers `ClaudeSDKClient`** for multi-turn conversations within a single process — it tracks session IDs automatically across `client.query()` calls. Use `query()` for one-shot tasks; use `ClaudeSDKClient` for continuous conversations.

### Key Options (`ClaudeAgentOptions` / `Options`)

| Option (Python / TS) | Type | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `string[]` | Auto-approve these tools (no prompt) |
| `disallowed_tools` / `disallowedTools` | `string[]` | Block these tools entirely |
| `permission_mode` / `permissionMode` | string | Permission behavior (see Permission Modes) |
| `system_prompt` / `systemPrompt` | string | Custom system prompt |
| `max_turns` / `maxTurns` | number | Cap tool-use turns; stops with `error_max_turns` |
| `max_budget_usd` / `maxBudgetUsd` | number | Cost cap; stops with `error_max_budget_usd` |
| `effort` | string | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | string | Override the model (e.g. `"claude-sonnet-4-6"`) |
| `resume` | string | Resume a session by ID |
| `fork_session` / `forkSession` | boolean | Fork a session from `resume` ID |
| `continue_conversation` / `continue` | boolean | Resume the most recent session in cwd |
| `mcp_servers` / `mcpServers` | object | MCP server configurations |
| `agents` | object | Subagent definitions |
| `hooks` | object | Hook callbacks |
| `setting_sources` / `settingSources` | string[] | Which config sources to load (`"project"`, `"user"`, `"local"`) |
| `cwd` | string | Working directory for the agent |
| `persist_session` / `persistSession` | boolean | TypeScript only: false = memory-only session |
| `include_partial_messages` / `includePartialMessages` | boolean | Enable streaming partial tokens |

### Message Types

| Python class | TypeScript `type` | When yielded |
| :--- | :--- | :--- |
| `SystemMessage` (subtype `"init"`) | `"system"` / `"init"` | First message; session metadata, MCP status, tools |
| `AssistantMessage` | `"assistant"` | After each Claude response (text + tool calls) |
| `UserMessage` | `"user"` | After each tool execution with results |
| `StreamEvent` | `"stream_event"` | When `includePartialMessages` is true; raw API events |
| `ResultMessage` | `"result"` | End of loop; final text, cost, usage, session ID |
| `SystemMessage` (subtype `"compact_boundary"`) | `SDKCompactBoundaryMessage` (TS) | After automatic context compaction |

**Checking types — Python:** `isinstance(message, ResultMessage)`. **TypeScript:** `message.type === "result"`. In TypeScript, content blocks are at `message.message.content`, not `message.content`.

### Result Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`. Check `stop_reason` (`"end_turn"`, `"max_tokens"`, `"refusal"`) to see why the model stopped on its last turn.

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read files |
| `Write` | Create files |
| `Edit` | Edit existing files |
| `Bash` | Run shell commands, scripts, git |
| `Monitor` | Watch a background script, react to each output line |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web pages |
| `ToolSearch` | Dynamically load tools on demand (reduces context) |
| `Agent` | Spawn subagents |
| `Skill` | Invoke a skill |
| `AskUserQuestion` | Ask user clarifying questions with multiple choice |
| `TodoWrite` | Track tasks |

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Unmatched tools call `canUseTool` callback; no callback = deny |
| `acceptEdits` | Auto-approves file edits (`Edit`, `Write`) and filesystem Bash (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) within cwd |
| `dontAsk` | Anything not in allow rules is denied; `canUseTool` never called |
| `bypassPermissions` | All tools run without prompts (deny rules still apply) |
| `plan` | Read-only tools only; Claude plans without editing files |
| `auto` (TS only) | Model classifier approves/denies each tool call |

**Permission evaluation order:** Hooks → Deny rules (`disallowedTools`) → Permission mode → Allow rules (`allowedTools`) → `canUseTool` callback.

**Note:** `allowedTools` pre-approves listed tools but does not constrain `bypassPermissions`. To block specific tools in bypass mode, use `disallowedTools`.

### Sessions

| Approach | Python | TypeScript | When to use |
| :--- | :--- | :--- | :--- |
| One-shot | `query()` | `query()` | Single task, no follow-up |
| Multi-turn (same process) | `ClaudeSDKClient` | `continue: true` | Chat, REPL, follow-up questions |
| Resume specific session | `resume=session_id` | `resume: sessionId` | Return to a past session by ID |
| Continue most recent | `continue_conversation=True` | `continue: true` | Pick up after process restart |
| Fork | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Try alternative without losing original |

Session files live at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `<encoded-cwd>` replaces non-alphanumeric chars with `-`. The `cwd` must match when resuming.

Session utilities: `list_sessions()` / `listSessions()`, `get_session_messages()` / `getSessionMessages()`, `get_session_info()` / `getSessionInfo()`, `rename_session()` / `renameSession()`, `tag_session()` / `tagSession()`.

### Hooks

Hooks are callbacks that fire at agent lifecycle events. Configure via `options.hooks`.

| Hook Event | Py | TS | Trigger | Common use |
| :--- | :---: | :---: | :--- | :--- |
| `PreToolUse` | Y | Y | Before tool executes | Block dangerous commands, modify input |
| `PostToolUse` | Y | Y | After tool returns | Audit, side effects, modify output |
| `PostToolUseFailure` | Y | Y | Tool execution failure | Log/handle errors |
| `PostToolBatch` | N | Y | Full batch resolves | Inject conventions once per batch |
| `UserPromptSubmit` | Y | Y | Prompt submitted | Inject additional context |
| `Stop` | Y | Y | Agent finishes | Save state, validate result |
| `SubagentStart` | Y | Y | Subagent spawned | Track parallel tasks |
| `SubagentStop` | Y | Y | Subagent completes | Aggregate parallel results |
| `PreCompact` | Y | Y | Context compaction | Archive full transcript |
| `PermissionRequest` | Y | Y | Permission dialog | Custom permission logic |
| `Notification` | Y | Y | Status messages | Forward to Slack/PagerDuty |
| `SessionStart` | N | Y | Session init | Logging, telemetry setup |
| `SessionEnd` | N | Y | Session termination | Clean up resources |
| `Setup` | N | Y | Session maintenance | Init tasks |

Hook callback signature: `(input_data, tool_use_id, context) → {}`. Return `{}` to allow; return `hookSpecificOutput.permissionDecision: "deny"` to block. Use `systemMessage` (top-level) to inject context into the conversation. Use `async: true` / `async_: True` for fire-and-forget side effects.

**Matcher:** regex on tool name (e.g., `"Write|Edit"`, `"^mcp__"`, omit for all). Matchers filter by tool name only — check `tool_input.file_path` inside the callback for path-based filtering.

**Multiple hooks:** all matching hooks run in parallel; `deny` wins over `ask` wins over `allow`.

`SessionStart`/`SessionEnd` are TS-only as SDK callbacks. In Python, use shell command hooks in `.claude/settings.json` with `setting_sources=["project"]`.

### Subagents

Define subagents via the `agents` option. Include `"Agent"` in `allowedTools` (Claude invokes subagents via the Agent tool).

**`AgentDefinition` fields:**

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When to use this agent (Claude reads this) |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Allowed tools (omit = inherit all) |
| `disallowedTools` | No | Tools to remove from the set |
| `model` | No | Override model: alias (`"sonnet"`, `"opus"`, `"haiku"`) or full ID |
| `maxTurns` | No | Turn cap for this subagent |
| `effort` | No | Reasoning effort for this subagent |
| `permissionMode` | No | Permission mode for this subagent |
| `mcpServers` | No | MCP servers for this subagent |
| `skills` | No | Skills to preload into this subagent |
| `background` | No | Run as non-blocking background task |

Subagents get a fresh context (no parent history). Pass needed data explicitly in the prompt. Parent receives only the subagent's final message. Subagents cannot spawn their own subagents (no `Agent` in their tools).

**Common tool combinations for subagents:**

| Purpose | Tools |
| :--- | :--- |
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Test execution | `Bash`, `Read`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Grep`, `Glob` |

### MCP Servers

**Transport types:** `stdio` (local processes via command/args), `sse` (remote), `http` / `streamable-http` (remote).

**MCP tool naming:** `mcp__<server-name>__<tool-name>`. Wildcard: `mcp__github__*`.

```typescript
options: {
  mcpServers: {
    github: { command: "npx", args: ["-y", "@modelcontextprotocol/server-github"],
              env: { GITHUB_TOKEN: process.env.GITHUB_TOKEN } }
  },
  allowedTools: ["mcp__github__list_issues"]
}
```

**Config file alternative:** `.mcp.json` at project root, loaded when `settingSources` includes `"project"`.

**Tool search:** Enabled by default. Withholds tool definitions from context until needed — reduces context cost when many MCP tools are configured.

**Auth:** `env` field for stdio; `headers` for HTTP/SSE; OAuth: pass token via headers after completing flow.

**Error handling:** Check `system/init` message for `mcp_servers[].status !== "connected"` before the agent starts.

### Custom Tools

Define in-process tools using `@tool` decorator (Python) or `tool()` function (TypeScript), then wrap in `create_sdk_mcp_server` / `createSdkMcpServer` and pass to `mcpServers`.

```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("get_weather", "Returns current weather for a city")
async def get_weather(city: str) -> str:
    return f"Sunny in {city}"

server = create_sdk_mcp_server([get_weather])
options = ClaudeAgentOptions(mcp_servers={"local": server})
```

Set `readOnlyHint: true` in tool annotations to allow parallel execution. Return `isError: true` (instead of throwing) to handle errors without stopping the agent loop.

### Structured Outputs

Pass a JSON Schema (or Zod/Pydantic model) to get validated typed output.

```typescript
for await (const message of query({
  prompt: "Extract recipe details from this text",
  options: {
    outputSchema: z.object({ name: z.string(), ingredients: z.array(z.string()) })
  }
})) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.structured_output); // typed object
  }
}
```

On validation failure after retry limit: result subtype is `error_max_structured_output_retries`.

### Streaming Output

Set `include_partial_messages: True` / `includePartialMessages: true` to receive `StreamEvent` messages with raw API events (text deltas, tool input chunks) as they arrive.

### Context Management

Context accumulates across turns (system prompt, tool defs, history, tool I/O). Automatic compaction fires near the limit — older messages are summarized. Control via:

- **CLAUDE.md summarization instructions** — include a section the compactor should follow
- **`PreCompact` hook** — run logic before compaction (e.g., archive full transcript)
- **Manual compaction** — send `"/compact"` as a prompt string

Effort level (`"low"` → `"max"`) controls reasoning depth per turn. Default: Python leaves unset; TypeScript defaults to `"high"`.

### Claude Code Features in the SDK

Load filesystem-based config via `setting_sources` / `settingSources`:

| Source | What it loads |
| :--- | :--- |
| `"project"` | `.claude/settings.json`, `.mcp.json`, `CLAUDE.md`, skills, agents, commands |
| `"user"` | `~/.claude/settings.json`, `~/.claude/CLAUDE.md` |
| `"local"` | `.claude/settings.local.json` |

### Observability (OpenTelemetry)

Export traces, metrics, and events via OTLP to Honeycomb, Datadog, Grafana, Langfuse, etc. Configure via environment variables or SDK options. Cost and token usage are also available directly from `ResultMessage.total_cost_usd` and `ResultMessage.usage`.

### Hosting

The SDK requires container-based sandboxing for production. Each instance needs Python 3.10+ (Python SDK) or Node.js 18+ (TypeScript SDK). The packages bundle a native Claude Code binary — no separate Claude Code install needed. Configure network controls, credential management, and resource limits per the secure deployment guide.

### Migration from Claude Code SDK

| | Old | New |
| :--- | :--- | :--- |
| TypeScript package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Import (Python) | `claude_code_sdk` | `claude_agent_sdk` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — introduction, capabilities, built-in tools, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — build a bug-fixing agent in minutes, permission modes, customization
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, compaction, result handling
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; cross-host session management
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, callback API, inputs/outputs, async hooks, examples
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, dynamic mode changes
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, context isolation, parallelization, tool restrictions, resuming subagents
- [MCP servers](references/claude-code-agent-sdk-mcp.md) — transport types, tool naming, auth, tool search, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — in-process MCP server, tool definitions, annotations, error handling, structured data
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — `query()`, `startup()`, `tool()`, `Options`, all types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — `query()`, `ClaudeSDKClient`, `@tool`, `ClaudeAgentOptions`, all types
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — enable `includePartialMessages`, `StreamEvent` handling
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to stream vs collect all messages
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, error handling
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion`, interactive approval flows
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, slash commands, plugins
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom and appended system prompts
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage` fields, per-turn tracking
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, events
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool for task tracking
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — load tools on demand to reduce context
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — use CLI slash commands as SDK prompt strings
- [Skills](references/claude-code-agent-sdk-skills.md) — load and invoke skills from the SDK
- [Plugins](references/claude-code-agent-sdk-plugins.md) — load plugins programmatically
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container sandboxing, resource requirements, deployment patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrate from old `claude-code-sdk` / `@anthropic-ai/claude-code` packages
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — deprecated V2 session API reference

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- MCP servers: https://code.claude.com/docs/en/agent-sdk/mcp.md
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
- Streaming vs single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
