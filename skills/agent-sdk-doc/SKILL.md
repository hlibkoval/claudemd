---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents in Python and TypeScript with built-in tools, sessions, hooks, permissions, subagents, MCP servers, custom tools, structured outputs, streaming, hosting, and secure deployment.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

The Agent SDK lets you embed Claude's autonomous agent loop into your own Python or TypeScript applications. Install with `pip install claude-agent-sdk` or `npm install @anthropic-ai/claude-agent-sdk`.

### Installation and authentication

| Method | Setup |
| :--- | :--- |
| Anthropic API | `export ANTHROPIC_API_KEY=your-api-key` |
| Amazon Bedrock | `export CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Google Vertex AI | `export CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `export CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Core entry point: `query()`

```python
from claude_agent_sdk import query, ClaudeAgentOptions
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({ prompt: "...", options: { ... } })) { ... }
```

### Built-in tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| File operations | `Read`, `Edit`, `Write` | Read, modify, and create files |
| Search | `Glob`, `Grep` | Find files by pattern, search content with regex |
| Execution | `Bash` | Run shell commands, scripts, git operations |
| Web | `WebSearch`, `WebFetch` | Search the web, fetch and parse pages |
| Monitoring | `Monitor` | Watch background scripts and react to output lines |
| Discovery | `ToolSearch` | Load tools on-demand instead of preloading all |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite` | Spawn subagents, invoke skills, ask user, track tasks |

### Key `ClaudeAgentOptions` / `Options` fields

| Option (Python / TypeScript) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Pre-approve these tools (no prompts) |
| `disallowed_tools` / `disallowedTools` | Block these tools entirely |
| `permission_mode` / `permissionMode` | Global permission mode (see below) |
| `max_turns` / `maxTurns` | Cap tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | Cap cost before stopping |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Model ID (e.g. `"claude-sonnet-4-6"`); defaults to Claude Code default |
| `system_prompt` / `systemPrompt` | Custom system prompt |
| `mcp_servers` / `mcpServers` | MCP server configs |
| `hooks` | Hook callbacks (see Hooks section) |
| `agents` | Subagent definitions |
| `resume` | Resume a prior session by ID |
| `continue_conversation` / `continue` | Resume the most recent session in `cwd` |
| `fork_session` / `forkSession` | Branch a session without modifying the original |
| `setting_sources` / `settingSources` | Which config sources to load (`"project"`, `"user"`, etc.) |
| `output_format` / `outputFormat` | JSON Schema for structured output |

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | Unmatched tools call your `canUseTool` callback; no callback = deny |
| `acceptEdits` | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, `mv`, `cp`, etc.) |
| `dontAsk` | Anything not in `allowedTools` is denied; `canUseTool` never called |
| `plan` | No tool execution; Claude produces a plan only |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call |
| `bypassPermissions` | All tools run without prompts (use only in isolated environments) |

Permission evaluation order: Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

### Message types

| Type | When emitted | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` | Session init and compaction boundary | `subtype` (`"init"` / `"compact_boundary"`), `session_id` |
| `AssistantMessage` | After each Claude turn | `content` (text + tool call blocks) |
| `UserMessage` | After each tool execution | `content` (tool results) |
| `StreamEvent` | Only with partial messages enabled | Raw API streaming events |
| `ResultMessage` | End of agent loop | `subtype`, `result`, `session_id`, `total_cost_usd`, `usage`, `num_turns` |

**Python:** use `isinstance(message, ResultMessage)`. **TypeScript:** use `message.type === "result"`.

### Result subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

### Sessions

| Approach | How |
| :--- | :--- |
| Single query | One `query()` call, no extras |
| Multi-turn (Python) | `ClaudeSDKClient` — tracks session automatically across `client.query()` calls |
| Multi-turn (TypeScript) | Pass `continue: true` on subsequent `query()` calls |
| Resume specific session | Capture `session_id` from `ResultMessage`, pass as `resume` option |
| Fork a session | Pass `resume: sessionId` plus `forkSession: true`; original unchanged |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `cwd` must match when resuming.

### Hooks

Hooks are callback functions registered in `options.hooks`. Structure: `{ EventName: [{ matcher?: "regex", hooks: [callback] }] }`.

| Hook Event | Python | TypeScript | When it fires |
| :--- | :--- | :--- | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes (can block / modify) |
| `PostToolUse` | Yes | Yes | After a tool returns |
| `PostToolUseFailure` | Yes | Yes | After a tool fails |
| `PostToolBatch` | No | Yes | After a full batch of tool calls |
| `UserPromptSubmit` | Yes | Yes | When a prompt is submitted |
| `Stop` | Yes | Yes | When agent finishes |
| `SubagentStart` / `SubagentStop` | Yes | Yes | Subagent spawns or completes |
| `PreCompact` | Yes | Yes | Before context compaction |
| `PermissionRequest` | Yes | Yes | Permission dialog would appear |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` / `SessionEnd` | No | Yes | Session init / termination |

**Callback signature:** `(input_data, tool_use_id, context) -> dict`

**Key output fields:**
- Return `{}` to allow without changes
- `hookSpecificOutput.permissionDecision`: `"allow"`, `"deny"`, `"ask"`, or `"defer"` (TS only)
- `hookSpecificOutput.updatedInput`: replace tool input (must also set `permissionDecision: "allow"`)
- `hookSpecificOutput.additionalContext`: append to tool result (PostToolUse)
- `systemMessage`: inject text visible to the model
- `continue` / `continue_`: whether agent keeps running after this hook
- `async_` / `async: true`: return immediately without blocking agent

### Subagents

Include `Agent` in `allowedTools`. Define via `agents` option:

```python
agents={
    "code-reviewer": AgentDefinition(
        description="When to use this agent",
        prompt="System prompt for the agent",
        tools=["Read", "Grep", "Glob"],  # optional; omit to inherit all
        model="sonnet",  # optional alias or full model ID
    )
}
```

**AgentDefinition fields:** `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model`, `skills`, `memory`, `mcpServers`, `maxTurns`, `background`, `effort`, `permissionMode`.

Subagents start fresh (no parent conversation history). They receive: their own `prompt`, project `CLAUDE.md`, and their tool set. They do NOT receive the parent's conversation history or system prompt.

### MCP servers

MCP tool naming: `mcp__{server-name}__{tool-name}` (e.g. `mcp__github__list_issues`).

| Transport | Config |
| :--- | :--- |
| stdio | `{ command: "npx", args: [...], env: {...} }` |
| HTTP | `{ type: "http", url: "...", headers: {...} }` |
| SSE | `{ type: "sse", url: "...", headers: {...} }` |
| In-process | `createSdkMcpServer` / `create_sdk_mcp_server` with `tool()` / `@tool` |

Use `allowedTools: ["mcp__servername__*"]` to pre-approve all tools from a server.

### Custom tools

Define with `@tool` (Python) or `tool()` (TypeScript), wrap in `createSdkMcpServer` / `create_sdk_mcp_server`, pass via `mcpServers`:

```python
@tool("name", "description", {"param": str})
async def my_tool(args): return {"content": [{"type": "text", "text": "..."}]}
server = create_sdk_mcp_server(name="myserver", version="1.0.0", tools=[my_tool])
```

Handler return value: `{ content: [{ type: "text"|"image"|"resource", ... }], isError?: true }`.

Tool annotations: `readOnlyHint` (enables parallel execution), `destructiveHint`, `idempotentHint`, `openWorldHint`.

### Structured outputs

Pass a JSON Schema, Zod schema (TypeScript), or Pydantic model (Python) via `output_format` / `outputFormat`. On success, `ResultMessage.structured_output` contains the validated data.

### Context window management

- Content accumulates across turns (system prompt, CLAUDE.md, conversation history, tool I/O)
- Prompt caching reduces cost for repeated prefixes
- Automatic compaction fires when context approaches the limit; emits `compact_boundary` message
- Use subagents for subtasks to isolate context
- `ToolSearch` loads MCP tools on-demand instead of preloading all

### Effort levels

| Level | Good for |
| :--- | :--- |
| `"low"` | File lookups, listing directories |
| `"medium"` | Routine edits, standard tasks |
| `"high"` | Refactors, debugging (TypeScript SDK default) |
| `"xhigh"` | Coding and agentic tasks; recommended on Opus 4.7 |
| `"max"` | Multi-step problems requiring deep analysis |

### Streaming output vs single-turn

- **Streaming input (recommended):** persistent session, supports image uploads, queued messages, hooks, real-time feedback, multi-turn context. Use `ClaudeSDKClient` (Python) or async generator `prompt` (TypeScript).
- **Single message input:** simpler, one-shot; no image attachments, no hooks, no dynamic queueing.

### Hosting requirements

Each SDK instance needs Python 3.10+ or Node.js 18+. Run inside a container for isolation. Both SDK packages bundle a native Claude Code binary; no separate CLI install needed.

For secure deployment: use network controls, short-lived credentials, least-privilege tool sets, and `disallowedTools` for dangerous operations. See the secure deployment reference.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK introduction, built-in tools, capabilities summary, comparison to Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step setup, first agent, key concepts, permission modes, troubleshooting
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, compaction, result handling
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full Python API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, hook types
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full TypeScript API: `query()`, `Options`, all message types, hook types, V1 stable API
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable V2 API with `createSession()` / `send` / `stream` pattern
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; session storage; cross-host resume
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, dynamic mode changes, `canUseTool` callback
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matchers, callback inputs/outputs, examples (blocking, modifying input, webhooks, Slack notifications)
- [Subagents](references/claude-code-agent-sdk-subagents.md) — programmatic agent definitions, `AgentDefinition` config, invocation, context inheritance, tool restrictions, resuming subagents
- [MCP servers](references/claude-code-agent-sdk-mcp.md) — transport types (stdio, HTTP, SSE, in-process), authentication, tool search, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool` decorator, `createSdkMcpServer`, error handling, images/resources, annotations
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, retry behavior, error handling
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — partial messages, real-time text and tool call deltas
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — comparison of streaming input mode vs single message input
- [User input and approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive approval flows
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md / skills / hooks from the filesystem
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage` fields, token breakdowns, interpreting costs
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, tracing, monitoring SDK agents in production
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container sandboxing, system requirements, deployment patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation options, security hardening
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — loading and using skills from the filesystem in SDK agents
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — sending slash commands (e.g. `/compact`) as SDK inputs
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool for task tracking within agent sessions
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — on-demand tool loading to reduce context window usage
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — using Claude Code plugins from SDK agents
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — CLAUDE.md memory, custom system prompts, `appendSystemPrompt`
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from the old Claude Code SDK to the Claude Agent SDK

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
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
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
