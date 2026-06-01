---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — a Python and TypeScript library for building production AI agents that run the Claude Code agent loop programmatically.

## Quick Reference

### Installation

| Language | Package | Requirement |
|:---------|:--------|:------------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ (bundles Claude Code binary) |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

Authentication: set `ANTHROPIC_API_KEY`. Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), Claude Platform on AWS (`CLAUDE_CODE_USE_ANTHROPIC_AWS=1`), and Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Core Entry Points

| API | Python | TypeScript | Use case |
|:----|:-------|:-----------|:---------|
| One-off query | `query(prompt, options)` | `query({prompt, options})` | Single task |
| Multi-turn session | `ClaudeSDKClient` (async context mgr) | `query()` with `continue: true` | Ongoing conversation in one process |
| Pre-warm subprocess | — | `startup({options})` → `WarmQuery` | Amortize startup latency |

Both `query()` and `ClaudeSDKClient` return async iterables of `SDKMessage` / `Message` objects.

### Built-in Tools

| Tool | Description |
|:-----|:------------|
| `Read` | Read files |
| `Write` | Create files |
| `Edit` | Edit existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script, react to each output line |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web pages |
| `AskUserQuestion` | Ask user clarifying questions with multiple-choice options |
| `Agent` | Invoke a subagent |
| `Skill` | Invoke a skill by name |

### Permission Modes

| Mode | Behavior | Use case |
|:-----|:---------|:---------|
| `default` | Unmatched tools call `canUseTool` callback | Interactive / custom approval flows |
| `acceptEdits` | Auto-approves file edits + `mkdir`, `touch`, `mv`, `cp`, `rm`, `sed` (inside cwd) | Trusted development workflows |
| `dontAsk` | Denies anything not pre-approved by `allowedTools`/rules | Locked-down headless agents |
| `plan` | Read-only tools only; Claude proposes without executing changes | Code review/planning |
| `auto` (TypeScript only) | Model classifier approves/denies each tool call | Autonomous agents with safety guardrails |
| `bypassPermissions` | All tools run without prompts; requires `allowDangerouslySkipPermissions: true` | Sandboxed CI, fully trusted environments |

### Allow and Deny Rules

| Option | Effect |
|:-------|:-------|
| `allowedTools: ["Read", "Grep"]` | Auto-approve these tools; others fall through to `permissionMode` |
| `disallowedTools: ["Bash"]` | Remove tool from Claude's context entirely |
| `disallowedTools: ["Bash(rm *)"]` | Block matching calls even in `bypassPermissions`; other Bash calls fall through |
| `allowedTools: ["mcp__github__*"]` | Wildcard: approve all tools from that MCP server |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

### Key Options (Python `ClaudeAgentOptions` / TypeScript `Options`)

| Option (Python / TypeScript) | Default | Description |
|:-----------------------------|:--------|:------------|
| `allowed_tools` / `allowedTools` | `[]` | Auto-approve listed tools (does not restrict unlisted tools) |
| `disallowed_tools` / `disallowedTools` | `[]` | Block listed tools; bare name removes from context, scoped pattern `Tool(pattern)` blocks matching calls |
| `permission_mode` / `permissionMode` | `"default"` | Global permission behavior |
| `max_turns` / `maxTurns` | none | Cap tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | none | Stop when client-side cost estimate exceeds this value |
| `effort` | `None` / `"high"` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `thinking` | adaptive | `ThinkingConfig`: `{type:"adaptive"}`, `{type:"enabled", budget_tokens:N}`, `{type:"disabled"}` |
| `model` | SDK default | Claude model to use |
| `system_prompt` / `systemPrompt` | minimal | Custom string or `{"type": "preset", "preset": "claude_code", "append": "..."}` |
| `cwd` | process cwd | Working directory |
| `setting_sources` / `settingSources` | all sources | Which filesystem settings to load: `"user"`, `"project"`, `"local"` or `[]` |
| `mcp_servers` / `mcpServers` | `{}` | MCP server configurations |
| `strict_mcp_config` / `strictMcpConfig` | `False` | Use only programmatic servers; ignore `.mcp.json` and settings-file servers |
| `agents` | `None` | Programmatic subagent definitions (`AgentDefinition`) |
| `hooks` | `None` | Hook callback configuration |
| `resume` | `None` | Session ID to resume |
| `continue_conversation` / `continue` | `False` / `false` | Resume most recent session in cwd |
| `fork_session` / `forkSession` | `False` | Fork instead of continuing resumed session |
| `skills` | `None` | `"all"` or list of skill names to enable |
| `plugins` | `[]` | Load local plugins: `[{"type": "local", "path": "..."}]` |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `False` | Enable file snapshot/rewind support |
| `session_store` / `sessionStore` | `None` | External session storage adapter for cross-host resume |
| `output_format` / `outputFormat` | `None` | `{"type": "json_schema", "schema": {...}}` for structured output |
| `env` | `{}` | Environment variables merged into the CLI subprocess env |
| `sandbox` | `None` | `SandboxSettings` for container/sandbox configuration |
| `persist_session` / `persistSession` (TS) | `True` | Set `false` to disable session disk writes |
| `can_use_tool` / `canUseTool` | `None` | Custom permission callback for tool approval |

### Message Types

| Type | Python check | TypeScript check | When emitted |
|:-----|:-------------|:-----------------|:-------------|
| `SystemMessage` (subtype `"init"`) | `isinstance(msg, SystemMessage) and msg.subtype == "init"` | `msg.type === "system" && msg.subtype === "init"` | First message; contains session ID, tools, MCP servers, permissionMode |
| `AssistantMessage` | `isinstance(msg, AssistantMessage)` | `msg.type === "assistant"` | Each Claude response turn; `parent_tool_use_id` set inside subagents |
| `UserMessage` | `isinstance(msg, UserMessage)` | `msg.type === "user"` | After each tool result |
| `ResultMessage` | `isinstance(msg, ResultMessage)` | `msg.type === "result"` | Final message; contains result, cost, usage, session ID |
| `StreamEvent` | (with `include_partial_messages=True`) | (with `includePartialMessages: true`) | Partial streaming deltas |

### Result Subtypes

| Subtype | `result` field | Meaning |
|:--------|:---------------|:--------|
| `"success"` | Yes | Task completed normally |
| `"error_max_turns"` | No | Hit `maxTurns` limit |
| `"error_max_budget_usd"` | No | Hit `maxBudgetUsd` limit |
| `"error_during_execution"` | No | API failure or cancellation |
| `"error_max_structured_output_retries"` | No | Structured output validation failed |

All result subtypes carry `total_cost_usd`, `usage`, `modelUsage`, `num_turns`, `session_id`, `stop_reason`, and `terminal_reason`.

**`terminal_reason` values:** `completed`, `max_turns`, `tool_deferred`, `aborted_streaming`, `aborted_tools`, `hook_stopped`, `stop_hook_prevented`, `blocking_limit`, `rapid_refill_breaker`, `prompt_too_long`, `image_error`, `model_error`.

### Sessions

| Pattern | Python | TypeScript | Use case |
|:--------|:-------|:-----------|:---------|
| Single query | `query(...)` | `query(...)` | One-off task |
| Multi-turn (same process) | `ClaudeSDKClient` | `continue: true` | Ongoing conversation |
| Resume most recent | `continue_conversation=True` | `continue: true` | Pick up after process restart |
| Resume specific | `resume=session_id` | `resume: sessionId` | Return to a prior run by ID |
| Fork | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Branch conversation without losing original |

Session ID: read from `ResultMessage.session_id` (both SDKs); also from `SystemMessage.data["session_id"]` (Python) or init `SystemMessage.session_id` (TypeScript).

Session files stored at: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`

Session utilities — Python: `list_sessions()`, `get_session_messages()`, `get_session_info()`, `rename_session()`, `tag_session()` · TypeScript: `listSessions()`, `getSessionMessages()`, `getSessionInfo()`, `renameSession()`, `tagSession()`

### Hooks (SDK Programmatic)

| Event | Python | TypeScript | Common use |
|:------|:-------|:-----------|:-----------|
| `PreToolUse` | Yes | Yes | Block/modify tool calls before execution |
| `PostToolUse` | Yes | Yes | Audit outputs, trigger side effects |
| `PostToolUseFailure` | Yes | Yes | Handle tool errors |
| `PostToolBatch` | No | Yes | Inject context once after a parallel batch |
| `UserPromptSubmit` | Yes | Yes | Inject context into prompts |
| `MessageDisplay` | No | Yes | Redact/reformat displayed assistant messages |
| `Stop` | Yes | Yes | Validate result, save state |
| `SubagentStart` / `SubagentStop` | Yes | Yes | Track parallel tasks |
| `PreCompact` | Yes | Yes | Archive transcript before compaction |
| `PermissionRequest` | Yes | Yes | Custom permission handling |
| `Notification` | Yes | Yes | Forward agent status to Slack, etc. |
| `SessionStart` / `SessionEnd` | No (file hooks only) | Yes | Session lifecycle |
| `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `Setup` | No | Yes | TypeScript-only lifecycle events |

Hook callback signature (Python): `async def my_hook(input_data, tool_use_id, context) -> dict`

Hook callback signature (TypeScript): `async (input: HookInput, toolUseID, { signal }) => Promise<HookJSONOutput>`

**Return values:**
- `{}` — allow with no change
- `{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": "..."}}` — block tool call
- `{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow", "updatedInput": {...}}}` — rewrite tool input
- `{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": "..."}}` — inject context after tool
- `{"async": true}` / `{"async_": True}` — return immediately, run hook as background side-effect

Hook priority when multiple hooks apply: deny > defer > ask > allow.

Python hook configuration:
```python
hooks={"PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])]}
```

TypeScript hook configuration:
```typescript
hooks: { PreToolUse: [{ matcher: "Write|Edit", hooks: [myCallback] }] }
```

### MCP Servers

Transport types:
- **stdio**: `{"command": "npx", "args": [...], "env": {...}}`
- **HTTP**: `{"type": "http", "url": "...", "headers": {...}}`
- **SSE**: `{"type": "sse", "url": "...", "headers": {...}}`
- **SDK in-process**: `createSdkMcpServer({name, tools})` / `create_sdk_mcp_server(name, tools=[...])`

Tool naming: `mcp__<server-name>__<tool-name>`. Wildcard: `mcp__github__*`.

MCP tool search (enabled by default): defers tool schemas until needed, saving context tokens. Set `strictMcpConfig: true` to ignore `.mcp.json` and use only programmatic servers.

### Subagents

Define via `agents` parameter in options. Include `Agent` in `allowedTools` to auto-approve subagent invocations.

```python
agents={
    "code-reviewer": AgentDefinition(
        description="Use for code quality and security reviews",
        prompt="You are a code review specialist...",
        tools=["Read", "Grep", "Glob"],
        model="sonnet",
    )
}
```

**Note (Python):** `AgentDefinition` field names use camelCase (`disallowedTools`, `maxTurns`, `permissionMode`) — not snake_case. Passing snake_case raises `TypeError`.

**`AgentDefinition` fields:** `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model` (`"sonnet"`, `"opus"`, `"haiku"`, `"inherit"`, or full ID), `maxTurns`, `background` (non-blocking background task), `skills`, `mcpServers`, `memory`, `effort`, `permissionMode`.

**What subagents inherit:** their own system prompt, project CLAUDE.md (via `settingSources`), and tool definitions. They do NOT receive parent conversation history, parent system prompt, or preloaded skills (unless listed in `AgentDefinition.skills`).

Subagents cannot spawn their own subagents; do not include `Agent` in a subagent's `tools` array.

**Common tool combos for subagents:**

| Use case | Tools |
|:---------|:------|
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Test execution | `Bash`, `Read`, `Grep` |
| Code modification | `Read`, `Edit`, `Write`, `Grep`, `Glob` |

### Custom Tools

```python
# Python: @tool decorator
@tool("get_weather", "Get current weather", {"latitude": float, "longitude": float})
async def get_weather(args):
    return {"content": [{"type": "text", "text": "72°F"}]}

server = create_sdk_mcp_server("my-tools", tools=[get_weather])
options = ClaudeAgentOptions(mcp_servers={"tools": server}, allowed_tools=["mcp__tools__get_weather"])
```

```typescript
// TypeScript: tool() function with Zod schema
import { z } from "zod";
const weatherTool = tool("get_weather", "Get current weather",
  { latitude: z.number(), longitude: z.number() },
  async ({ latitude, longitude }) => ({ content: [{ type: "text", text: "72°F" }] })
);
const server = createSdkMcpServer({ name: "my-tools", tools: [weatherTool] });
```

Set `readOnlyHint: true` in `ToolAnnotations` to allow parallel execution.

### settingSources

| Value | Loads from | Contents |
|:------|:-----------|:---------|
| `"project"` | `<cwd>/.claude/` | CLAUDE.md, `.claude/rules/*.md`, project skills, hooks, `settings.json` |
| `"user"` | `~/.claude/` | User CLAUDE.md, `rules/*.md`, user skills, user settings |
| `"local"` | `<cwd>/.claude/` | `settings.local.json`, `CLAUDE.local.md` |

Omitting `settingSources` = `["user", "project", "local"]`. Pass `[]` to disable filesystem settings (managed policy and `~/.claude.json` always load regardless).

### Context Window Management

- System prompt and CLAUDE.md are prompt-cached (cost paid once per session)
- Conversation history accumulates across turns
- MCP tool schemas load on demand (tool search) or upfront (when disabled)
- Automatic compaction fires near context limit; emits `compact_boundary` system message
- Manual compaction: send `"/compact"` as prompt string
- Subagents start fresh (no parent history), keeping main context lean

### TypeScript-only: `startup()` (pre-warm)

Pre-warms the CLI subprocess before a prompt is available, eliminating startup latency from the critical path:

```typescript
const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) { ... }
```

`WarmQuery` implements `AsyncDisposable`. Call `warm.close()` to discard without sending a prompt.

### TypeScript-only: `Query` object methods

| Method | Description |
|:-------|:------------|
| `interrupt()` | Interrupt in streaming input mode |
| `rewindFiles(userMessageId, {dryRun?})` | Restore files to state at that message (requires `enableFileCheckpointing`) |
| `setPermissionMode(mode)` | Change permission mode mid-session |
| `setModel(model?)` | Change model mid-session |
| `applyFlagSettings(settings)` | Merge settings into flag layer mid-session |
| `supportedCommands()` | List available slash commands |
| `supportedModels()` | List available models |
| `mcpServerStatus()` | Get MCP server connection status |
| `reconnectMcpServer(name)` | Retry connecting to an MCP server |
| `setMcpServers(servers)` | Dynamically replace MCP servers |
| `stopTask(taskId)` | Stop a running background task |
| `close()` | Terminate the process and clean up |

### TypeScript-only: `resolveSettings()`

Inspect merged effective settings without starting a query:

```typescript
const { effective, provenance } = await resolveSettings({ cwd: "/path/to/project" });
```

### Python-only: `ClaudeSDKClient`

Multi-turn client that reuses the same session:

```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("Analyze the auth module")
    async for message in client.receive_response():
        print(message)
    await client.query("Now refactor it")  # same session, full context
    async for message in client.receive_response():
        print(message)
```

Methods: `connect()`, `query()`, `receive_messages()`, `receive_response()`, `interrupt()`, `set_permission_mode()`, `set_model()`, `rewind_files()`, `get_mcp_status()`, `reconnect_mcp_server()`, `toggle_mcp_server()`, `stop_task()`, `get_server_info()`, `disconnect()`

**After calling `interrupt()`:** drain the interrupted task's messages with `receive_response()` before sending a new query — interrupt does not flush the buffer.

### Structured Output

Pass `output_format` / `outputFormat` with a JSON schema. Result subtypes: `"success"` (schema validated), `"error_max_structured_output_retries"` (retries exhausted).

### File Checkpointing

Set `enable_file_checkpointing=True` / `enableFileCheckpointing: true`. Then call `rewind_files(userMessageId)` / `rewindFiles(userMessageId)` to restore files to their state at that message.

### Secure Deployment Key Points

- Run the SDK in sandboxed containers (Modal, E2B, Fly Machines, Docker, etc.)
- Recommended per-instance: 1 GiB RAM, 5 GiB disk, 1 CPU
- Multi-tenant isolation: `settingSources: []`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, separate filesystem per tenant
- Use `disallowedTools` and scoped deny rules like `"Bash(curl *)"` for network restrictions
- Hooks run in-process before permission mode, enabling fine-grained enforcement

### API Timeout Env Vars (pass via `env` option)

| Variable | Default | Description |
|:---------|:--------|:------------|
| `API_TIMEOUT_MS` | 600000 | Per-request Anthropic API timeout |
| `CLAUDE_CODE_MAX_RETRIES` | 10 | Max API retries |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | 600000 | Stall watchdog for background subagents |
| `CLAUDE_ENABLE_STREAM_WATCHDOG` | off | Abort stalled streaming responses |

### SDK vs CLI vs Managed Agents

| | Agent SDK | Claude Code CLI | Managed Agents |
|:--|:----------|:----------------|:---------------|
| Runs in | Your process | Interactive terminal | Anthropic infrastructure |
| Interface | Python/TypeScript library | CLI | REST API |
| Best for | Local prototyping, CI/CD, apps on your filesystem | Interactive development | Production without managing sandbox/session infrastructure |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — What the Agent SDK is, capabilities overview, and comparison with CLI/Client SDK/Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent step by step; key concepts table for tools and permission modes
- [How the Agent Loop Works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, context window, compaction, result handling
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete `query()`, `Options`, `Query` object, all message types, hook types, MCP types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete `query()`, `ClaudeAgentOptions`, `ClaudeSDKClient`, all types and classes
- [Use Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, hooks from filesystem
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; session utilities; cross-host resumption
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Allow/deny rules, permission modes, dynamic mode switching
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Callback hooks guide with examples: block, modify input, audit, notifications
- [MCP](references/claude-code-agent-sdk-mcp.md) — Transport types, tool naming, authentication, tool search, error handling
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Define, invoke, tool restrictions, context inheritance, resuming subagents
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — `@tool` / `tool()`, in-process MCP server, annotations, error handling, images
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Partial messages, real-time streaming events
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use streaming input vs one-shot queries
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON schema output validation
- [User Input](references/claude-code-agent-sdk-user-input.md) — `AskUserQuestion`, `canUseTool` callback, interactive approval flows
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage` fields, per-model breakdown
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, tracing, and monitoring agent behavior
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and revert file changes
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for external backends (cross-host resumption)
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool loading to save context tokens
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom prompts, preset `claude_code` prompt, output styles, prompt cache optimization
- [Skills](references/claude-code-agent-sdk-skills.md) — Using skills programmatically with the SDK
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Sending `/compact` and other commands as SDK inputs
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading plugins via the `plugins` option
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Production deployment patterns, container requirements, sandbox providers
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Threat model, isolation technologies, multi-tenant hardening, network controls
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading between SDK versions
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Notes on the removed V2 session API
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — Task creation and tracking with `TaskCreate`/`TaskUpdate`

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
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
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
