---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: building production AI agents in Python and TypeScript, the agent loop, sessions, permissions, hooks, subagents, MCP, custom tools, hosting, observability, and full API references for both languages.

## Quick Reference

### Installation

| Language | Package | Requires |
|:---------|:--------|:---------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

The TypeScript SDK bundles a native Claude Code binary — no separate Claude Code install needed. Set `ANTHROPIC_API_KEY` before use.

### Entry Point

Both SDKs expose a `query()` function that returns an async iterator of messages:

```python
# Python
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
// TypeScript
for await (const message of query({ prompt: "...", options: { ... } })) { ... }
```

### Built-in Tools

| Tool | What it does |
|:-----|:-------------|
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `Monitor` | Watch a background script and react to output lines |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple choice |
| `Agent` | Spawn a subagent to handle a subtask |

### Permission Modes

| Mode | Behavior | Use case |
|:-----|:---------|:---------|
| `default` | No auto-approvals; unmatched tools call `canUseTool` | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and filesystem ops (`mkdir`, `rm`, `mv`, etc.) | Trusted dev workflows |
| `dontAsk` | Denies anything not in `allowedTools` without prompting | Locked-down headless agents |
| `auto` (TS only) | Model classifier approves or denies each call | Autonomous agents with guardrails |
| `bypassPermissions` | All tools run without prompts | Sandboxed CI, fully trusted envs |
| `plan` | Read-only tools only; Claude plans without editing | Code review, pre-approval workflows |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

`allowedTools` pre-approves listed tools. `disallowedTools` with a bare name removes the tool from Claude's context; with a scoped rule like `Bash(rm *)` it denies matching calls in every mode including `bypassPermissions`.

### Key `ClaudeAgentOptions` / `Options` Fields

| Python field | TypeScript field | Description |
|:-------------|:----------------|:------------|
| `allowed_tools` | `allowedTools` | Tools to auto-approve |
| `disallowed_tools` | `disallowedTools` | Tools to deny or remove |
| `permission_mode` | `permissionMode` | Permission mode (see table above) |
| `can_use_tool` | `canUseTool` | Custom permission callback |
| `system_prompt` | `systemPrompt` | Custom or preset system prompt |
| `mcp_servers` | `mcpServers` | MCP server configurations |
| `agents` | `agents` | Programmatic subagent definitions |
| `hooks` | `hooks` | SDK hook callbacks |
| `resume` | `resume` | Session ID to resume |
| `continue_conversation` | `continue` | Resume most recent session |
| `fork_session` | `forkSession` | Fork on resume instead of continuing |
| `max_turns` | `maxTurns` | Max agentic turns (tool round-trips) |
| `max_budget_usd` | `maxBudgetUsd` | Stop when cost estimate reaches this |
| `model` | `model` | Claude model to use |
| `effort` | `effort` | Thinking depth: `low`/`medium`/`high`/`xhigh`/`max` |
| `thinking` | `thinking` | Thinking config: `adaptive`, `enabled`, or `disabled` |
| `cwd` | `cwd` | Working directory for the agent |
| `setting_sources` | `settingSources` | Which settings files to load: `user`, `project`, `local` |
| `enable_file_checkpointing` | `enableFileCheckpointing` | Enable file rewind support |
| `session_store` | `sessionStore` | External session storage adapter |
| `plugins` | `plugins` | Load local plugins via `{ type: "local", path: "..." }` |
| `skills` | `skills` | Skills to enable: list of names or `"all"` |
| `output_format` | `outputFormat` | JSON Schema for structured output |
| `add_dirs` | `additionalDirectories` | Extra directories Claude can access |
| `sandbox` | `sandbox` | Sandbox behavior settings |
| `env` | `env` | Env vars (Python: merged; TypeScript: replaces, so spread `...process.env`) |

### Message Types (SDKMessage)

| Type / Subtype | Key fields | Meaning |
|:---------------|:-----------|:--------|
| `system` / `init` | `session_id`, `tools`, `model`, `permissionMode` | Session initialized |
| `assistant` | `message` (BetaMessage), `parent_tool_use_id` | Claude response with text and/or tool calls |
| `user` | `message`, `parent_tool_use_id` | User or tool result message |
| `result` / `success` | `result`, `total_cost_usd`, `usage`, `num_turns` | Task completed successfully |
| `result` / `error_max_turns` | `errors`, `total_cost_usd` | Stopped at `maxTurns` limit |
| `result` / `error_during_execution` | `errors` | Stopped due to execution error |
| `result` / `error_max_budget_usd` | `errors` | Stopped at cost limit |
| `system` / `compact_boundary` | `compact_metadata` | Context compaction occurred |
| `system` / `permission_denied` | `tool_name`, `decision_reason` | Tool auto-denied |

`parent_tool_use_id` is non-null on messages from within a subagent's context.

The `terminal_reason` field on result messages: `"completed"`, `"max_turns"`, `"tool_deferred"`, `"aborted_streaming"`, `"aborted_tools"`, `"hook_stopped"`, `"stop_hook_prevented"`, `"blocking_limit"`, `"rapid_refill_breaker"`, `"prompt_too_long"`, `"image_error"`, or `"model_error"`.

### Sessions

| Approach | Python | TypeScript | When to use |
|:---------|:-------|:-----------|:------------|
| Single query | `query()` | `query()` | One-off task |
| Auto multi-turn | `ClaudeSDKClient` | `continue: true` | Chat in one process |
| Resume most recent | `continue_conversation=True` | `continue: true` | Pick up after restart |
| Resume specific | `resume=session_id` | `resume: sessionId` | Multi-session app |
| Fork | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Explore alternative approach |

Sessions are stored at `~/.claude/projects/<encoded-cwd>/*.jsonl`. Sessions are conversation history only — not filesystem state. Use file checkpointing to snapshot and revert files.

Session utility functions:

| Python | TypeScript | Description |
|:-------|:-----------|:------------|
| `list_sessions(directory, limit)` | `listSessions({ dir, limit })` | List past sessions with metadata |
| `get_session_messages(session_id)` | `getSessionMessages(sessionId)` | Read messages from a past session |
| `get_session_info(session_id)` | `getSessionInfo(sessionId)` | Metadata for a single session |
| `rename_session(session_id, title)` | `renameSession(sessionId, title)` | Set a custom title |
| `tag_session(session_id, tag)` | `tagSession(sessionId, tag)` | Tag a session (pass `None`/`null` to clear) |

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
|:--------|:----------|:-----------------|
| Session | New each call (unless `resume`/`continue`) | Reuses same session |
| Interrupts | No | Yes (`interrupt()`) |
| Multi-turn | Manual via `resume`/`continue` | Automatic |
| Use case | One-off tasks | Continuous conversations |

### TypeScript: `Query` Object Methods

| Method | Description |
|:-------|:------------|
| `interrupt()` | Interrupt (streaming input mode only) |
| `setPermissionMode(mode)` | Change permission mode mid-session |
| `setModel(model)` | Change model mid-session |
| `applyFlagSettings(settings)` | Merge settings into flag layer at runtime |
| `rewindFiles(userMessageId)` | Restore files to state at that message (requires `enableFileCheckpointing`) |
| `supportedModels()` | Returns available models |
| `mcpServerStatus()` | Returns MCP server statuses |
| `setMcpServers(servers)` | Dynamically replace MCP servers |
| `stopTask(taskId)` | Stop a background task |
| `close()` | Terminate the underlying process |

`startup()` pre-warms the CLI subprocess for lower latency on the first `query()` call.

### Hooks (SDK-level callbacks)

SDK hooks are callback functions passed in `options.hooks`, not shell commands. They use the same event names as file-based hooks.

```python
# Python hook matcher
HookMatcher(matcher="Edit|Write", hooks=[my_callback])
```

```typescript
// TypeScript hook matcher
{ matcher: "Edit|Write", hooks: [myCallback] }
```

Available `HookEvent` values: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PermissionRequest`, `Setup`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `MessageDisplay`, `Notification`.

Hook callbacks return a `HookJSONOutput` dict. For `PreToolUse`, returning `{ "hookSpecificOutput": { "permissionDecision": "deny", "permissionDecisionReason": "..." } }` blocks the tool call.

### Subagents (`AgentDefinition`)

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When to use this agent (natural language) |
| `prompt` | Yes | The agent's system prompt |
| `tools` | No | Allowed tool names (inherits all if omitted) |
| `disallowedTools` | No | Tools to explicitly remove |
| `model` | No | Model override: alias (`"sonnet"`, `"opus"`, `"haiku"`, `"inherit"`) or full model ID |
| `skills` | No | Skill names to preload into agent context |
| `maxTurns` | No | Max agentic turns for this agent |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Effort level for this agent |
| `permissionMode` | No | Permission mode for this agent |
| `mcpServers` | No | MCP server specs (names or inline configs) |
| `memory` | No | Memory source: `"user"`, `"project"`, or `"local"` |

Include `"Agent"` in `allowedTools` to auto-approve subagent invocations. Define agents in `options.agents` keyed by name; Claude uses the Agent tool to invoke them.

**Note (Python):** `AgentDefinition` fields use camelCase (`disallowedTools`, `permissionMode`, `maxTurns`) because they map directly to the wire format.

### MCP Server Config Types

| Type | Key fields | Transport |
|:-----|:-----------|:---------|
| `stdio` (default) | `command`, `args?`, `env?` | stdin/stdout subprocess |
| `sse` | `url`, `headers?` | HTTP Server-Sent Events |
| `http` | `url`, `headers?` | HTTP streaming |
| `sdk` | `name`, `instance` | In-process MCP server |

Use `tool()` / `@tool` decorator plus `createSdkMcpServer()` / `create_sdk_mcp_server()` to define in-process MCP tools. MCP tool names follow `mcp__<server>__<tool>` naming.

`strictMcpConfig`/`strict_mcp_config`: when `true`, ignores project `.mcp.json` and user settings; only uses explicitly passed servers.

### Custom Tools (In-process MCP)

**TypeScript:**
```typescript
const myTool = tool("name", "description", { param: z.string() }, async ({ param }) => ({
  content: [{ type: "text", text: `Result: ${param}` }]
}));
const server = createSdkMcpServer({ name: "my-server", tools: [myTool] });
// Pass server to options.mcpServers["my-server"]
```

**Python:**
```python
@tool("name", "description", {"param": str})
async def my_tool(args): return {"content": [{"type": "text", "text": args["param"]}]}
server = create_sdk_mcp_server(name="my-server", tools=[my_tool])
# Pass server to ClaudeAgentOptions(mcp_servers={"my-server": server})
```

### Structured Outputs

Pass `output_format`/`outputFormat` with `{ "type": "json_schema", "schema": {...} }` to have Claude's final result validated against a JSON Schema. The result appears in `SDKResultMessage.structured_output`.

### System Prompt Options

| Value | Effect |
|:------|:-------|
| String | Use as custom system prompt |
| `{ type: "preset", preset: "claude_code" }` | Use Claude Code's full system prompt |
| `{ type: "preset", preset: "claude_code", append: "..." }` | Preset + appended instructions |
| `{ type: "preset", ..., excludeDynamicSections: true }` | Move per-session context to first user message for better prompt cache reuse |

### `settingSources` / `setting_sources`

Controls which filesystem settings files are loaded. Values: `"user"` (`~/.claude/settings.json`), `"project"` (`.claude/settings.json`), `"local"` (`.claude/settings.local.json`). Pass `[]` to load none. Managed policy settings always load regardless of this option.

**Note (Python SDK 0.1.59 and earlier):** an empty list was treated as omitting the option. Upgrade to apply `setting_sources=[]`.

### File Checkpointing

Set `enable_file_checkpointing=True` / `enableFileCheckpointing: true` to track file changes. Call `rewindFiles(userMessageId)` on the Query object (TypeScript) or `client.rewind_files(user_message_id)` (Python `ClaudeSDKClient`) to restore files to their state at that message. Pass `{ dryRun: true }` to preview.

### Session Storage (External)

Implement the `SessionStore` interface to mirror transcripts to S3, Redis, Postgres, or any backend, enabling resume across hosts. Pass the adapter as `session_store`/`sessionStore` in options. Reference implementations available in the session-storage reference doc.

### Hosting Patterns

| Pattern | Container lifetime | Best for |
|:--------|:------------------|:---------|
| Ephemeral | One container per task, destroyed on completion | One-off tasks (bug fix, document conversion) |
| Long-running | Persistent, multiple sessions per container | Ongoing agents (email, chatbot, site builder) |
| Hybrid | Ephemeral + `SessionStore` for resume across restarts | Intermittent sessions (research, support) |
| Multi-agent | Multiple SDK subprocesses in one container | Tightly collaborating agents |

Multi-tenant isolation: use `settingSources: []`, `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, per-tenant `cwd`, and per-tenant `CLAUDE_CONFIG_DIR`.

Observability: set `CLAUDE_CODE_ENABLE_TELEMETRY=1`, `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`, and standard OTEL env vars. The SDK exports traces, metrics, and logs via OTLP.

Container baseline: 1 GiB RAM, 5 GiB disk, 1 CPU per agent. Needs outbound HTTPS to `api.anthropic.com`.

### Streaming Input Mode vs Single Message

| Feature | Streaming input (AsyncGenerator prompt) | Single message (string prompt) |
|:--------|:----------------------------------------|:------------------------------|
| Image attachments | Yes | No |
| Message queueing | Yes | No |
| Real-time interrupt | Yes | No |
| Multi-turn (natural) | Yes | Via `resume`/`continue` |
| Stateless lambda | No | Yes |

Streaming mode: pass an `AsyncGenerator` as `prompt`. In TypeScript, use `query.streamInput(stream)`. In Python, use `ClaudeSDKClient`.

### API Timeout Controls (via `env`)

| Variable | Default | Description |
|:---------|:--------|:------------|
| `API_TIMEOUT_MS` | `600000` | Per-request timeout (ms) |
| `CLAUDE_CODE_MAX_RETRIES` | `10` | Max API retries |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | `600000` | Stall watchdog for background subagents |
| `CLAUDE_ENABLE_STREAM_WATCHDOG` | off | Abort stalled response body stream (set to `1`) |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | `300000` | Idle threshold for stream watchdog |

**TypeScript:** `env` replaces the subprocess environment — always spread `...process.env`. **Python:** `env` merges on top of inherited environment.

### `SdkBeta`

Only known value: `"context-1m-2025-08-07"` — **retired as of April 30, 2026**. Passing it with Sonnet 4.5 or Sonnet 4 has no effect. For 1M context, use Claude Sonnet 4.6, Opus 4.6, or Opus 4.7 (no beta header required).

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK capabilities, built-in tools, capabilities summary, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step: install, set API key, build a bug-fixing agent, run it
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How the agentic loop works: turns, tool calls, message streaming, handling results
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete TypeScript API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all Options fields, all message types, hook types, session functions
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete Python API: `query()`, `ClaudeSDKClient`, `@tool`, `create_sdk_mcp_server()`, `ClaudeAgentOptions`, all types, message classes
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; automatic session management; session IDs; cross-host resume
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface, S3/Redis/Postgres reference adapters, conformance testing
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission evaluation flow, allow/deny rules, permission modes, `canUseTool` callback
- [User Input](references/claude-code-agent-sdk-user-input.md) — Interactive approval prompts, `AskUserQuestion`, `canUseTool` callback pattern
- [Hooks](references/claude-code-agent-sdk-hooks.md) — SDK hook callbacks: events, `HookMatcher`, blocking, `PreToolUse` decisions, common patterns
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP tools: `tool()` decorator, `createSdkMcpServer()`, `ToolAnnotations`
- [MCP](references/claude-code-agent-sdk-mcp.md) — Connect to MCP servers: stdio, SSE, HTTP, in-process; `strictMcpConfig`; dynamic server management
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Define and spawn subagents; `AgentDefinition`; background agents; subagent message routing
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema output format; `structured_output` on result message; retry behavior
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Message stream patterns; partial messages; filtering for human-readable output
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use streaming input (AsyncGenerator) vs string prompt
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom system prompts, preset system prompt, appending, prompt cache optimization
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Loading CLAUDE.md, settings, skills, slash commands; what `settingSources` does not control
- [Skills](references/claude-code-agent-sdk-skills.md) — Using skills in SDK agents; `skills` option; `Skill` tool
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Using slash commands and legacy `.claude/commands/` files in SDK sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading local plugins with `SdkPluginConfig`
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Enable, capture message IDs, rewind files, dry-run preview
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage`, `modelUsage` on result; `maxBudgetUsd` cap; accuracy caveats
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry setup; OTEL env vars; traces, metrics, logs; sensitive data controls
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — Agent task progress via todo lists; `SDKTaskProgressMessage`; `agentProgressSummaries`
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Deferred tool loading with `ToolSearch`; schema discovery at runtime
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns (ephemeral/long-running/hybrid/multi-agent), container provisioning, multi-tenant isolation
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Network controls, credential management, isolation technologies, sandbox providers
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Migrating from `claude -p` CLI usage to the Agent SDK

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
