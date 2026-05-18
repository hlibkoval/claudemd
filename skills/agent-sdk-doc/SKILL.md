---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — query() API, agent loop, message types, built-in tools, permission modes and rules, hooks (PreToolUse/PostToolUse/Stop/etc.), sessions (resume/continue/fork), subagents, custom tools via in-process MCP, MCP server configuration, streaming output, structured outputs, system prompt customization, cost tracking, hosting, observability, file checkpointing, and full TypeScript/Python SDK references.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### Installation

| SDK | Package | Install |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

The TypeScript SDK bundles a native Claude Code binary — no separate Claude Code CLI install needed.

Authentication: set `ANTHROPIC_API_KEY`. Also supports `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1`, `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`.

### Core API

**TypeScript:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({ prompt, options })) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    if isinstance(message, ResultMessage) and message.subtype == "success":
        print(message.result)
```

**Python multi-turn (`ClaudeSDKClient`):**
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("First prompt")
    async for msg in client.receive_response(): ...
    await client.query("Follow-up")
    async for msg in client.receive_response(): ...
```

### Key Options (`ClaudeAgentOptions` / `Options`)

| Option (Python → TS) | Type | Description |
| :--- | :--- | :--- |
| `allowed_tools` → `allowedTools` | `string[]` | Auto-approve these tools (no prompt) |
| `disallowed_tools` → `disallowedTools` | `string[]` | Always block these tools |
| `tools` | `string[]` | Restrict which built-in tools are in Claude's context |
| `permission_mode` → `permissionMode` | string | See permission modes table |
| `system_prompt` → `systemPrompt` | string or preset | Custom or `claude_code` preset |
| `max_turns` → `maxTurns` | number | Cap tool-use turns |
| `max_budget_usd` → `maxBudgetUsd` | number | Cap spend |
| `effort` | `"low"/"medium"/"high"/"xhigh"/"max"` | Reasoning depth |
| `model` | string | Model ID or alias (`"sonnet"`, `"opus"`, `"haiku"`) |
| `mcp_servers` → `mcpServers` | object | MCP server configs keyed by server name |
| `hooks` | object | SDK callback hooks |
| `agents` | object | Subagent definitions |
| `resume` | string | Resume a past session by ID |
| `fork_session` → `forkSession` | boolean | Fork the session being resumed |
| `continue` (TS only) | boolean | Resume most recent session in cwd |
| `continue_conversation` (Python only) | boolean | Resume most recent session in cwd |
| `setting_sources` → `settingSources` | string[] | Which config sources to load (`"project"`, `"user"`, `"local"`) |
| `cwd` | string | Working directory for the agent |
| `include_partial_messages` → `includePartialMessages` | boolean | Enable streaming `StreamEvent` messages |
| `persist_session` → `persistSession` (TS only) | boolean | Set `false` for in-memory-only session |

### Permission Modes

| Mode | Behavior | Best for |
| :--- | :--- | :--- |
| `"default"` | Unmatched tools trigger `canUseTool` callback; no callback = deny | Interactive apps with custom approval |
| `"acceptEdits"` | Auto-approves file edits and filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`); others follow default | Trusted dev workflows |
| `"dontAsk"` | Denies anything not pre-approved by `allowedTools` or rules; `canUseTool` never called | Locked-down headless agents |
| `"plan"` | Read-only; Claude can explore but not edit source files | Dry-run / review without changes |
| `"auto"` (TS only) | Model classifier approves/denies each call | Autonomous agents with safety guardrails |
| `"bypassPermissions"` | All tools run without prompts (blocks if root on Unix) | Isolated CI/containers |

Permission evaluation order: **hooks → deny rules → permission mode → allow rules → `canUseTool` callback**.

`allowed_tools` does NOT constrain `bypassPermissions` — deny rules (`disallowedTools`) are the only way to block in that mode.

Subagents inherit the parent's permission mode and cannot override `bypassPermissions`, `acceptEdits`, or `auto`.

### Message Types

| Type | When yielded | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` (`type: "system"`) | Session start (`subtype: "init"`), compaction boundary | `session_id` (TS direct field; Python in `.data`) |
| `AssistantMessage` (`type: "assistant"`) | Each Claude response | `.content[]` blocks (Python direct; TS via `.message.content`) |
| `UserMessage` (`type: "user"`) | After each tool execution | Tool results fed back to Claude |
| `StreamEvent` (`type: "stream_event"`) | Only when `includePartialMessages: true` | `.event` with `content_block_delta` / `text_delta` |
| `ResultMessage` (`type: "result"`) | End of loop | `subtype`, `result`, `total_cost_usd`, `usage`, `session_id`, `num_turns` |

**Result subtypes:**

| Subtype | Meaning | `result` available? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Schema validation failed after retries | No |

Always iterate the stream to completion rather than breaking on `ResultMessage` — trailing system events can follow.

### Built-in Tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| File ops | `Read`, `Edit`, `Write` | Read, modify, create files |
| Search | `Glob`, `Grep` | Find files by pattern, search content with regex |
| Execution | `Bash` | Shell commands, scripts, git |
| Web | `WebSearch`, `WebFetch` | Search the web, parse pages |
| Discovery | `ToolSearch` | Load MCP tool schemas on demand |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite` | Spawn subagents, invoke skills, ask user, track tasks |

Parallel execution: read-only tools run concurrently; state-modifying tools run sequentially. Custom tools default to sequential; set `readOnlyHint: true` to enable parallel.

### SDK Hooks (Callback Functions)

Configure under `options.hooks` as `{ EventName: [{ matcher?, hooks: [callbackFn] }] }`.

| Hook Event | Python | TypeScript | When it fires | Common use |
| :--- | :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes (can block/modify) | Validate inputs, block dangerous commands |
| `PostToolUse` | Yes | Yes | After a tool returns | Audit, trigger side effects |
| `PostToolUseFailure` | Yes | Yes | Tool execution failure | Log/handle errors |
| `PostToolBatch` | No | Yes | Full parallel batch resolves | Inject conventions for the whole batch |
| `UserPromptSubmit` | Yes | Yes | Prompt submitted | Inject context |
| `Stop` | Yes | Yes | Agent finishes | Save session state |
| `SubagentStart` | Yes | Yes | Subagent spawns | Track parallel tasks |
| `SubagentStop` | Yes | Yes | Subagent completes | Aggregate results |
| `PreCompact` | Yes | Yes | Before context compaction | Archive transcript |
| `PermissionRequest` | Yes | Yes | Permission dialog triggered | Custom permission handling |
| `Notification` | Yes | Yes | Agent status messages | Forward to Slack/PagerDuty |
| `SessionStart` | No | Yes | Session starts | Logging/telemetry init |
| `SessionEnd` | No | Yes | Session ends | Cleanup resources |
| `Setup` | No | Yes | Init/maintenance trigger | Initialization tasks |
| `TeammateIdle` | No | Yes | Teammate goes idle | Reassign work |
| `TaskCompleted` | No | Yes | Background task completes | Aggregate results |
| `ConfigChange` | No | Yes | Config file changes | Reload settings |
| `WorktreeCreate/Remove` | No | Yes | Git worktree lifecycle | Track workspaces |

**Callback signature:** `async (input_data, tool_use_id, context) → output`

**Output structure:**
- `{}` — allow without changes
- `{ hookSpecificOutput: { hookEventName, permissionDecision: "allow"|"deny"|"ask"|"defer", permissionDecisionReason, updatedInput } }` — PreToolUse
- `{ hookSpecificOutput: { hookEventName, additionalContext, updatedToolOutput } }` — PostToolUse
- `{ systemMessage, continue/continue_ }` — top-level fields (all events)
- `{ async_/async: true, asyncTimeout }` — fire-and-forget (side effects only)

Multiple hooks on one event run in parallel; deny wins over defer, defer over ask, ask over allow.

**Python:** `HookMatcher(matcher="Write|Edit", hooks=[callback])` in `ClaudeAgentOptions(hooks={...})`
**TypeScript:** `{ matcher: "Write|Edit", hooks: [callback] }` in `options.hooks`

`SessionStart`/`SessionEnd` not available as Python SDK callbacks — use shell hooks in `.claude/settings.json` with `setting_sources=["project"]`.

### Sessions

| Goal | How |
| :--- | :--- |
| One-shot task | Single `query()` call — no extra setup |
| Multi-turn in one process | Python: `ClaudeSDKClient`; TypeScript: `continue: true` |
| Resume most recent session | `continue_conversation=True` (Python) / `continue: true` (TS) |
| Resume specific session | `resume=session_id` (from `ResultMessage.session_id`) |
| Fork into alternative branch | `resume=session_id, fork_session=True` / `forkSession: true` |
| In-memory only (TS) | `persistSession: false` |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `cwd` must match to resume across hosts.

Session utility functions: `list_sessions()` / `listSessions()`, `get_session_messages()` / `getSessionMessages()`, `get_session_info()` / `getSessionInfo()`, `rename_session()` / `renameSession()`, `tag_session()` / `tagSession()`.

### Subagents (`agents` option)

Include `"Agent"` in `allowedTools` — subagents are invoked via the Agent tool.

```python
agents={
    "code-reviewer": AgentDefinition(
        description="When to use this agent",  # Claude reads this to decide
        prompt="System prompt for this agent",
        tools=["Read", "Grep"],           # Restrict tool access
        model="sonnet",                   # Override model
        effort="high",                    # Override effort
        max_turns=20,
    )
}
```

**`AgentDefinition` fields:** `description`\*, `prompt`\*, `tools`, `disallowedTools`, `model`, `skills`, `memory`, `mcpServers`, `maxTurns`, `background`, `effort`, `permissionMode`.

Subagent context: gets its own system prompt + Agent tool prompt + CLAUDE.md; does NOT get parent's conversation history or parent's system prompt. Only its final message returns to parent.

Subagents cannot spawn their own subagents (do not include `"Agent"` in a subagent's `tools`).

Detect subagent invocation: look for `tool_use` blocks with `name === "Agent"` (or `"Task"` for older SDK versions). Messages from inside a subagent have `parent_tool_use_id` set.

### Custom Tools (In-Process MCP)

**TypeScript:**
```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myTool = tool("tool_name", "description", { param: z.string() }, async (args) => ({
  content: [{ type: "text", text: "result" }]
}));
const server = createSdkMcpServer({ name: "my-server", version: "1.0.0", tools: [myTool] });

// Use it:
query({ prompt, options: { mcpServers: { "my-server": server }, allowedTools: ["mcp__my-server__tool_name"] } })
```

**Python:**
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("tool_name", "description", {"param": str})
async def my_tool(args): return {"content": [{"type": "text", "text": "result"}]}

server = create_sdk_mcp_server(name="my-server", version="1.0.0", tools=[my_tool])
```

Tool name format: `mcp__{server_name}__{tool_name}`. Wildcard: `mcp__my-server__*`.

Tool annotations (`readOnlyHint`, `destructiveHint`, `idempotentHint`, `openWorldHint`) — `readOnlyHint: true` enables parallel execution.

Return `isError: True` (not an exception) to let the agent loop continue on tool failure. Uncaught exceptions stop the loop.

Content block types: `text`, `image` (base64 `data` + `mimeType`), `resource` (uri + text/blob).

### MCP Server Configuration

```typescript
mcpServers: {
  // stdio process
  "my-server": { command: "node", args: ["server.js"], env: { KEY: "val" } },
  // HTTP/SSE
  "remote": { type: "http", url: "https://api.example.com/mcp" },
  // In-process SDK server
  "custom": myInProcessServer
}
```

MCP tool search (deferred loading) is on by default — MCP tool schemas are loaded on demand. Disabled on Vertex AI or non-first-party `ANTHROPIC_BASE_URL`, where all schemas load upfront.

Allow all tools on a server: `allowedTools: ["mcp__server-name__*"]`

### System Prompts

| Starting point | When to use |
| :--- | :--- |
| Minimal default (no `systemPrompt`) | Thin tool-calling loop; no agent persona needed |
| `{ type: "preset", preset: "claude_code" }` | CLI/IDE-like coding tool where human watches streaming output |
| `claude_code` preset + `append` | Same, plus product-specific rules (lowest-risk customization) |
| Custom string | Different surface, identity, or permission model; non-coding agents |

CLAUDE.md is injected as project context (not into the system prompt) and re-injected on every request, surviving compaction. Load via `setting_sources=["project"]`.

### Agent Loop Control

| Option | Controls | Default |
| :--- | :--- | :--- |
| `maxTurns` | Max tool-use round trips | No limit |
| `maxBudgetUsd` | Max cost before stopping | No limit |
| `effort` | Reasoning depth per turn | Python: model default; TS: `"high"` |

Effort levels: `"low"` (fast/cheap) → `"medium"` → `"high"` → `"xhigh"` (recommended for Opus 4.7) → `"max"` (deepest).

### Context Window

Context accumulates across turns: system prompt + CLAUDE.md + tool definitions + full conversation history. Static content (system prompt, CLAUDE.md, tool schemas) is prompt-cached automatically.

**Automatic compaction:** when context nears limit, older history is summarized. A `SystemMessage` with `subtype: "compact_boundary"` is emitted. Persistent rules belong in CLAUDE.md, not the initial prompt.

Strategies to keep context lean:
- Use subagents for subtasks (each starts fresh)
- Scope subagent `tools` to the minimum needed
- Use `ToolSearch` to defer MCP schema loading
- Lower `effort` for simple/routine tasks

**Manual compaction:** send `/compact` as the prompt string.

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true`. SDK yields `StreamEvent` messages with raw API events. Filter for `content_block_delta` events where `delta.type === "text_delta"` to get text chunks.

### Structured Outputs

Pass `output_schema` (Python) / `outputSchema` (TypeScript) with a JSON Schema, Zod schema, or Pydantic model. SDK re-prompts on mismatch up to the retry limit. On failure: `error_max_structured_output_retries` result subtype.

### Cost Tracking

`ResultMessage` fields: `total_cost_usd` / `costUSD` (client-side estimate, not authoritative billing), `usage` dict (input/output/cache tokens), `model_usage` / `modelUsage` (per-model breakdown).

`total_cost_usd` can be `None` on error paths in Python — guard before formatting.

For authoritative billing: use the Usage and Cost API or Claude Console.

### TypeScript `startup()` (pre-warm)

```typescript
import { startup } from "@anthropic-ai/claude-agent-sdk";
const warm = await startup({ options: { maxTurns: 3 } });
for await (const msg of warm.query("What files are here?")) { ... }
```

Moves subprocess spawn and initialization out of the critical path.

### Hosting Requirements

- Python 3.10+ or Node.js 18+; SDK bundles Claude Code binary
- Recommended: 1GiB RAM, 5GiB disk, 1 CPU
- Network: outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production

Sandbox providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox.

### Migration Note

TypeScript V2 session API (`createSession()` with `send`/`stream`) is deprecated. Use V1 `query()` function with `continue`/`resume` options instead.

Agent tool name change: `"Task"` → `"Agent"` in SDK v2.1.63. Check both names for compatibility.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — capabilities, comparison to Client SDK and Managed Agents, quickstart
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step setup, first agent, common patterns
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, compaction, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full API: `query()`, `startup()`, `tool()`, all types and interfaces
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full API: `query()`, `ClaudeSDKClient`, `@tool`, all types and classes
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — experimental V2 session API (deprecated, use V1)
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, cross-host resumption, session utilities
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, dynamic mode changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — callback hooks, matchers, outputs, async hooks, troubleshooting
- [Subagents](references/claude-code-agent-sdk-subagents.md) — defining, invoking, tool restrictions, resuming, detecting invocation
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — in-process MCP server, tool definitions, annotations, error handling, images/resources
- [MCP](references/claude-code-agent-sdk-mcp.md) — external MCP server configuration, transports, tool search, authentication
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred MCP schema loading, configuration
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — enable partial messages, handle StreamEvent
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use each input mode
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, error handling
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` approval callback, `AskUserQuestion`
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — preset vs custom, CLAUDE.md, append, output styles
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — skills, slash commands, memory, plugins via `settingSources`
- [Skills](references/claude-code-agent-sdk-skills.md) — loading skills in SDK context
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — sending `/compact` and other commands as prompt strings
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — token usage, per-model costs, caching, prompt caching
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, telemetry integration
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — task tracking with the `TodoWrite` tool
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container sandboxing, system requirements, production patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from `claude -p` CLI to the SDK

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
