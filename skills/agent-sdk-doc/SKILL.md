---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — Python and TypeScript SDKs, query() and ClaudeSDKClient APIs, ClaudeAgentOptions/Options fields, permission modes and allow/deny rules, hooks (PreToolUse, PostToolUse, Stop, and more), sessions (continue, resume, fork), subagents, MCP servers, custom tools, streaming vs single-mode, structured outputs, cost tracking, file checkpointing, session storage, observability with OpenTelemetry, secure deployment, and hosting.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### What the Agent SDK Is

The Agent SDK is a Python and TypeScript library that embeds Claude Code's autonomous agent loop in your application. Claude handles tool execution, context management, and retries — you just consume the stream.

```
pip install claude-agent-sdk          # Python
npm install @anthropic-ai/claude-agent-sdk  # TypeScript
```

Set `ANTHROPIC_API_KEY` (or configure Bedrock, Vertex AI, or Azure credentials).

### Installation and Entry Points

| Language | Entry point | Continuous conversation |
| :--- | :--- | :--- |
| Python | `from claude_agent_sdk import query, ClaudeAgentOptions` | `ClaudeSDKClient` |
| TypeScript | `import { query } from "@anthropic-ai/claude-agent-sdk"` | `query()` with `continue: true` |

### `query()` — Core API

Both SDKs expose `query()` as the primary entry point. It returns an async iterator/generator that streams messages as the agent works.

**Python signature:**
```python
async def query(*, prompt: str | AsyncIterable, options: ClaudeAgentOptions | None = None) -> AsyncIterator[Message]
```

**TypeScript signature:**
```typescript
function query({ prompt, options }: { prompt: string | AsyncIterable<SDKUserMessage>; options?: Options }): Query
```

The `Query` object (TypeScript) extends `AsyncGenerator` with methods: `interrupt()`, `rewindFiles()`, `setPermissionMode()`, `setModel()`, `applyFlagSettings()`, `mcpServerStatus()`, `reconnectMcpServer()`, `toggleMcpServer()`, `setMcpServers()`, `streamInput()`, `stopTask()`, `close()`.

### Key Options (Python `ClaudeAgentOptions` / TypeScript `Options`)

| Option (Python / TypeScript) | Default | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `[]` | Tools auto-approved without prompting. Does NOT restrict Claude to only these. |
| `disallowed_tools` / `disallowedTools` | `[]` | Bare name removes tool from context; scoped rule (`"Bash(rm *)"`) denies matching calls in all modes including `bypassPermissions` |
| `permission_mode` / `permissionMode` | `"default"` | Global permission mode |
| `system_prompt` / `systemPrompt` | `None` | Custom string or `{"type": "preset", "preset": "claude_code"}` |
| `mcp_servers` / `mcpServers` | `{}` | MCP server configurations |
| `max_turns` / `maxTurns` | `None` | Cap on tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | `None` | Stop when client-side cost estimate reaches this USD value |
| `resume` | `None` | Session ID to resume |
| `continue_conversation` / `continue` | `False` | Resume most recent session in current directory |
| `fork_session` / `forkSession` | `False` | Fork to new session ID instead of continuing original |
| `agents` | `None` | Programmatic subagent definitions |
| `hooks` | `None` | Hook callback configurations |
| `model` | `None` | Claude model override |
| `effort` | `None` / `'high'` | Thinking depth: `low`, `medium`, `high`, `xhigh`, `max` |
| `thinking` | `None` | `ThinkingConfig`: `adaptive`, `enabled` (with `budget_tokens`), or `disabled` |
| `setting_sources` / `settingSources` | All sources | Which filesystem settings to load: `"user"`, `"project"`, `"local"`. Pass `[]` to disable all |
| `cwd` | `None` | Working directory |
| `skills` | `None` | Pass `"all"` or a list of skill names; enables Skill tool automatically |
| `plugins` | `[]` | Load local plugins: `[{"type": "local", "path": "./my-plugin"}]` |
| `output_format` / `outputFormat` | `None` | `{"type": "json_schema", "schema": {...}}` for structured output |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `False` | Track file changes for rewinding |
| `session_store` / `sessionStore` | `None` | Mirror session to external storage backend |
| `sandbox` | `None` | Programmatic sandbox configuration |
| `can_use_tool` / `canUseTool` | `None` | Runtime tool permission callback |
| `strict_mcp_config` / `strictMcpConfig` | `False` | Use only programmatic MCP servers, ignore settings files |
| `include_partial_messages` / `includePartialMessages` | `False` | Yield `StreamEvent` messages for real-time streaming |
| `agents` | `None` / `undefined` | Programmatically defined subagents |

### Permission Modes

| Mode | Behavior |
| :--- | :--- |
| `acceptEdits` | Auto-approves file edits and common filesystem operations |
| `dontAsk` | Denies anything not in `allowed_tools` (no prompts) |
| `auto` (TypeScript only) | Model classifier approves/denies each tool call |
| `bypassPermissions` | Runs every tool without prompts (requires `allowDangerouslySkipPermissions: true` in TypeScript) |
| `plan` | Read-only tools only |
| `default` | Falls through to `canUseTool` callback for unmatched tools |

### Permission Evaluation Order

1. **Hooks** — can deny outright or pass on (a hook returning `allow` does NOT skip deny/ask rules)
2. **Deny rules** — `disallowed_tools` scoped rules (bare names already removed tool from context)
3. **Permission mode** — `bypassPermissions` approves all that reach this step
4. **Allow rules** — `allowed_tools` approves matched tools
5. **`canUseTool` callback** — handles remaining (skipped in `dontAsk` mode, which denies)

### Message Types

| Type | When | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` / `SDKSystemMessage` | Session init | `subtype: "init"`, session metadata: tools, model, mcp_servers, skills |
| `AssistantMessage` / `SDKAssistantMessage` | After each Claude response | `message.content` (text blocks, tool call blocks) |
| `UserMessage` / `SDKUserMessage` | After each tool execution | `message.content` (tool results) |
| `ResultMessage` / `SDKResultMessage` | End of loop | `subtype`, `result`, `total_cost_usd`, `usage`, `session_id`, `num_turns` |
| `StreamEvent` / `SDKPartialAssistantMessage` | When `includePartialMessages` enabled | Raw API streaming events |

`ResultMessage.subtype` values: `"success"`, `"error_max_turns"`, `"error_during_execution"`, `"error_max_budget_usd"`, `"error_max_structured_output_retries"`.

**Python:** check with `isinstance(message, ResultMessage)`.
**TypeScript:** check with `message.type === "result"`. Content blocks are at `message.message.content`, not `message.content`.

### Sessions

| Approach | How | Best for |
| :--- | :--- | :--- |
| One-shot | Default `query()` call | Single tasks |
| Continue (most recent) | `continue_conversation=True` / `continue: true` | Multi-turn in same or restarted process |
| Resume (specific) | `resume="<session-id>"` | Multi-user apps, specific past sessions |
| Fork | `resume + fork_session=True` | Try alternative approach, keep original |
| No persistence (TS only) | `persistSession: false` | Stateless tasks |

**Session utility functions:**

| Function | Description |
| :--- | :--- |
| `list_sessions()` / `listSessions()` | List past sessions with metadata |
| `get_session_info()` / `getSessionInfo()` | Get metadata for a single session by ID |
| `get_session_messages()` / `getSessionMessages()` | Read messages from a past session |
| `rename_session()` / `renameSession()` | Set a custom title |
| `tag_session()` / `tagSession()` | Tag a session (pass `None`/`null` to clear) |

**Python `ClaudeSDKClient`** maintains conversation across multiple `query()` calls in one process. Supports `interrupt()`, `set_permission_mode()`, `set_model()`, `rewind_files()`, `get_mcp_status()`, `reconnect_mcp_server()`, `toggle_mcp_server()`, `stop_task()`.

**TypeScript `startup()`** pre-warms the CLI subprocess before a prompt is available, removing spawn latency from the critical path.

### Hooks

SDK hooks are callback functions (not shell commands). Configure via `options.hooks`.

```python
# Python
hooks={
    "PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])]
}

# TypeScript
hooks: {
    PreToolUse: [{ matcher: "Write|Edit", hooks: [myCallback] }]
}
```

**Callback signature:**
- Python: `async def callback(input_data, tool_use_id, context) -> dict`
- TypeScript: `(input: HookInput, toolUseID: string | undefined, options: { signal: AbortSignal }) => Promise<HookJSONOutput>`

**Available hook events:** `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PermissionRequest`, `Setup`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`

**Hook output for `PreToolUse` (permission control):**
```python
return {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",          # or "allow", "ask", "defer"
        "permissionDecisionReason": "reason",
        "updatedInput": {...}                  # optional: modify tool input
    }
}
```

To block universally: return `{"continue": false, "stopReason": "message"}`.
To inject context for Claude: return `{"hookSpecificOutput": {"hookEventName": "...", "additionalContext": "..."}}`.

### Custom Tools (`@tool` decorator / `tool()` function)

**Python:**
```python
@tool("tool-name", "description", {"param": str})
async def my_tool(args: dict) -> dict:
    return {"content": [{"type": "text", "text": result}]}

server = create_sdk_mcp_server(name="my-server", tools=[my_tool])
options = ClaudeAgentOptions(mcp_servers={"srv": server}, allowed_tools=["mcp__srv__tool-name"])
```

**TypeScript (uses Zod schema):**
```typescript
const myTool = tool("tool-name", "description", { param: z.string() },
  async ({ param }) => ({ content: [{ type: "text", text: result }] })
);
const server = createSdkMcpServer({ name: "my-server", tools: [myTool] });
```

### Subagents

Define via the `agents` option. Include `"Agent"` in `allowedTools` to auto-approve subagent invocations.

```python
# Python
AgentDefinition(
    description="When to use this agent",   # required
    prompt="System prompt / instructions",   # required
    tools=["Read", "Grep"],                  # optional: restrict tools
    model="sonnet",                          # optional: model alias or full ID
    maxTurns=10,                             # camelCase in AgentDefinition
    background=True,                         # run as non-blocking task
)
```

Note: `AgentDefinition` fields use camelCase (`disallowedTools`, `permissionMode`, `maxTurns`) unlike `ClaudeAgentOptions` which uses snake_case.

**Context isolation:** subagent tool calls stay inside the subagent; only the final message returns to parent.
**Parallelization:** multiple subagents run concurrently.
**Filtering by source:** messages from subagents carry `parent_tool_use_id`.

### MCP Servers

```python
# Python: stdio
mcp_servers={"playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}}

# Python: SSE
mcp_servers={"api": {"type": "sse", "url": "https://...", "headers": {...}}}

# TypeScript: stdio
mcpServers: { playwright: { command: "npx", args: ["@playwright/mcp@latest"] } }
```

Tool names for allowed/disallowed rules: `mcp__<server-name>__<tool-name>`.

Use `strict_mcp_config` / `strictMcpConfig: true` to use only programmatic servers, ignoring `.mcp.json` and user settings.

### Structured Output

```python
# Python
options = ClaudeAgentOptions(output_format={"type": "json_schema", "schema": {...}})

# TypeScript
options = { outputFormat: { type: "json_schema", schema: {...} } }
```

Result in `ResultMessage.structured_output` (TypeScript) or `message.structured_output` (Python).

### Cost and Usage Tracking

`ResultMessage` includes `total_cost_usd` (client-side estimate), `usage` (`input_tokens`, `output_tokens`, `cache_read_input_tokens`, `cache_creation_input_tokens`), and `modelUsage` (per-model breakdown).
Use `max_budget_usd` / `maxBudgetUsd` to stop when the estimate exceeds a threshold.

### System Prompt Configuration

```python
# Custom system prompt
system_prompt="You are a senior Python developer."

# Use Claude Code's preset
system_prompt={"type": "preset", "preset": "claude_code"}

# Extend the preset
system_prompt={"type": "preset", "preset": "claude_code", "append": "Always write tests."}

# Exclude dynamic sections for better prompt cache reuse across machines
system_prompt={"type": "preset", "preset": "claude_code", "exclude_dynamic_sections": True}
```

### Settings Sources and Precedence

`setting_sources` / `settingSources` controls which filesystem settings load. Managed policy settings always load regardless.

Precedence (highest to lowest): Managed policy > programmatic options > local (`.claude/settings.local.json`) > project (`.claude/settings.json`) > user (`~/.claude/settings.json`).

Pass `setting_sources=[]` to disable all filesystem settings (SDK-only apps, CI). Note: Python SDK 0.1.59 and earlier treated `[]` as omitted.

### File Checkpointing

Enable with `enable_file_checkpointing=True` / `enableFileCheckpointing: true`. Then call `client.rewind_files(user_message_id)` (Python) or `query.rewindFiles(userMessageId)` (TypeScript) to restore files to their state at a specific message. TypeScript supports `{ dryRun: true }` to preview changes.

### Session Storage (External)

Pass a `SessionStore` implementation to `session_store` / `sessionStore` to mirror transcripts to an external backend (database, cloud storage). Allows any host to resume sessions. `session_store_flush` / `sessionStoreFlush`: `"batched"` (default) or `"eager"`.

### Observability

The SDK supports OpenTelemetry. Set `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_EXPORTER_OTLP_HEADERS` environment variables. Traces include span names for agent turns and tool calls. See reference doc for span attributes.

### Timeout Environment Variables (via `env` option)

| Variable | Default | Description |
| :--- | :--- | :--- |
| `API_TIMEOUT_MS` | `600000` | Per-request timeout in ms |
| `CLAUDE_CODE_MAX_RETRIES` | `10` | Max API retries |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | `600000` | Stall watchdog for background subagents |
| `CLAUDE_ENABLE_STREAM_WATCHDOG=1` + `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | off / `300000` | Abort stalled response streams |

### Hosting Requirements

- **Python 3.10+** or **Node.js 18+**. Both SDKs bundle a native Claude Code binary — no separate CLI install needed.
- **Resources:** 1 GiB RAM, 5 GiB disk, 1 CPU (adjust per task)
- **Network:** outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for isolation. Supported providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox.

### TypeScript-only Features

- `startup()` — pre-warm CLI subprocess before prompt is ready
- `resolveSettings()` — inspect merged settings without spawning Claude
- `applyFlagSettings()` — change any setting mid-session (streaming mode only)
- `persistSession: false` — disable session persistence to disk
- `agentProgressSummaries`, `forwardSubagentText`, `promptSuggestions`, `toolAliases`, `toolConfig`, `planModeInstructions`, `taskBudget`, `onElicitation`

### Python `ClaudeAgentOptions` Type Notes

`@dataclass` types (like `ResultMessage`, `AgentDefinition`, `TextBlock`) support attribute access: `msg.result`.
`TypedDict` types (like `ThinkingConfigEnabled`, `McpStdioServerConfig`) are plain dicts at runtime and require key access: `config["budget_tokens"]`, not `config.budget_tokens`.

### `AgentDefinition` Fields (both SDKs, camelCase)

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When Claude should use this agent |
| `prompt` | Yes | Agent's system prompt |
| `tools` | No | Allowed tool names (inherits all if omitted) |
| `disallowedTools` | No | Tools to remove from agent's context |
| `model` | No | Model alias (`"sonnet"`, `"opus"`, `"haiku"`, `"inherit"`) or full ID |
| `maxTurns` | No | Turn limit for this agent |
| `background` | No | Run as non-blocking background task |
| `skills` | No | Skill names to preload into agent context |
| `memory` | No | `"user"`, `"project"`, or `"local"` |
| `effort` | No | Effort level for this agent |
| `permissionMode` | No | Permission mode for this agent |
| `initialPrompt` | No | Auto-submitted as first user turn when agent runs as main thread |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities, built-in tools, comparison to Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step: install, set API key, create an agent, run it, customize
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, messages, context window, compaction, cost and turn limits
- [Agent SDK reference - Python](references/claude-code-agent-sdk-python.md) — full API: `query()`, `ClaudeSDKClient`, all `ClaudeAgentOptions` fields, all types and message classes
- [Agent SDK reference - TypeScript](references/claude-code-agent-sdk-typescript.md) — full API: `query()`, `Options`, `Query` object, `startup()`, all types and message types
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, permission modes
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive approval flows
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — hook events, callback functions, matchers, output format, blocking/modifying tool calls
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, `ClaudeSDKClient`, `listSessions`, `getSessionMessages`
- [Persist sessions to external storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface, implementing custom backends
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, context isolation, parallelization, specialized instructions
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — connecting MCP servers, tool naming, authentication
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — `@tool` decorator, `create_sdk_mcp_server()`, in-process MCP servers
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom prompts, Claude Code preset, `append`, `excludeDynamicSections`, output styles
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — skills, slash commands, CLAUDE.md, plugins, `settingSources` behavior
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — `skills` option, enabling skills programmatically
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — using slash commands in SDK sessions
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — `SdkPluginConfig`, loading local plugins
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, handling `StreamEvent` messages
- [Streaming Input](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — streaming input mode vs single-message mode
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — `outputFormat`, JSON schema validation, reading results
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage`, `modelUsage`, `maxBudgetUsd`
- [Rewind file changes with checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — `enableFileCheckpointing`, `rewindFiles()`
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — OTLP setup, span names and attributes
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — container requirements, resources, sandbox providers, deployment patterns
- [Securely deploying AI agents](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies (Docker, gVisor, Firecracker)
- [Todo Lists](references/claude-code-agent-sdk-todo-tracking.md) — how Claude uses TodoWrite/TodoRead for task tracking
- [Scale to many tools with tool search](references/claude-code-agent-sdk-tool-search.md) — `ToolSearch` tool, semantic tool discovery at scale
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — migrating from `claude -p` CLI usage
- [TypeScript SDK V2 session API (removed)](references/claude-code-agent-sdk-typescript-v2-preview.md) — deprecated V2 preview reference

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Agent SDK reference - Python: https://code.claude.com/docs/en/agent-sdk/python.md
- Agent SDK reference - TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Persist sessions to external storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming Input: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Rewind file changes with checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Securely deploying AI agents: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Todo Lists: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Scale to many tools with tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- TypeScript SDK V2 session API (removed): https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
