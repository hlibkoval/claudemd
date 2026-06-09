---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: the Python and TypeScript libraries for building production AI agents powered by Claude Code's agent loop, tools, sessions, hooks, permissions, MCP servers, subagents, and hosting infrastructure.

## Quick Reference

### Installation

| Language | Package | Requires |
|:---------|:--------|:---------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

### Core Entry Points

**TypeScript:** `query({ prompt, options? })` — returns an `AsyncGenerator<SDKMessage>`.

**Python:** `query(*, prompt, options?, transport?)` — returns an `AsyncIterator[Message]`. For multi-turn conversations use `ClaudeSDKClient`.

### Authentication

| Provider | Environment variable(s) |
|:---------|:------------------------|
| Anthropic (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Built-in Tools

| Category | Tools |
|:---------|:------|
| File operations | `Read`, `Edit`, `Write` |
| Search | `Glob`, `Grep` |
| Execution | `Bash` |
| Web | `WebSearch`, `WebFetch` |
| Discovery | `ToolSearch` |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate` |
| Monitoring | `Monitor` |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Tools not covered by allow rules call your `canUseTool` callback; no callback = deny |
| `acceptEdits` | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`); other Bash commands follow default rules |
| `plan` | Read-only tools run; Claude explores and plans without editing files |
| `dontAsk` | Never prompts; anything not pre-approved is denied |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call |
| `bypassPermissions` | All allowed tools run without prompting; cannot be used as root; use only in isolated environments |

### Key Options (Python: `ClaudeAgentOptions` / TypeScript: `Options`)

| Option | Python field | TypeScript field | Default |
|:-------|:------------|:----------------|:--------|
| Auto-approve tools | `allowed_tools` | `allowedTools` | `[]` |
| Block tools | `disallowed_tools` | `disallowedTools` | `[]` |
| Permission mode | `permission_mode` | `permissionMode` | `'default'` |
| Cap tool-use turns | `max_turns` | `maxTurns` | No limit |
| Cap cost | `max_budget_usd` | `maxBudgetUsd` | No limit |
| Reasoning depth | `effort` | `effort` | `None` / `'high'` |
| Model | `model` | `model` | CLI default |
| System prompt | `system_prompt` | `systemPrompt` | Minimal |
| Resume session | `resume` | `resume` | — |
| Continue most recent | `continue_conversation` | `continue` | `false` |
| Fork session | `fork_session` | `forkSession` | `false` |
| Working dir | `cwd` | `cwd` | `process.cwd()` |
| Settings sources | `setting_sources` | `settingSources` | All sources |
| MCP servers | `mcp_servers` | `mcpServers` | `{}` |
| Hooks | `hooks` | `hooks` | `{}` |
| Subagents | `agents` | `agents` | — |
| Plugins | `plugins` | `plugins` | `[]` |
| Streaming partial msgs | `include_partial_messages` | `includePartialMessages` | `false` |
| File checkpointing | `enable_file_checkpointing` | `enableFileCheckpointing` | `false` |
| Structured output | `output_format` | `outputFormat` | — |
| Session store | `session_store` | `sessionStore` | — |

### Effort Levels

| Level | Behavior | Good for |
|:------|:---------|:---------|
| `'low'` | Minimal reasoning | File lookups, listing directories |
| `'medium'` | Balanced reasoning | Routine edits, standard tasks |
| `'high'` | Thorough analysis (TypeScript default) | Refactors, debugging |
| `'xhigh'` | Extended reasoning depth | Coding and agentic tasks; recommended on Opus 4.7 |
| `'max'` | Maximum reasoning depth | Multi-step problems requiring deep analysis |

### Message Types (stream output)

| Type | Python class | TypeScript `type` field | When emitted |
|:-----|:------------|:------------------------|:-------------|
| System init | `SystemMessage` (subtype `"init"`) | `"system"` (subtype `"init"`) | First message; contains `session_id`, tools, model |
| Assistant turn | `AssistantMessage` | `"assistant"` | After each Claude response, including tool calls |
| Tool results | `UserMessage` | `"user"` | After each tool execution; carries tool result |
| Partial streaming | `StreamEvent` | `"stream_event"` | Only when `includePartialMessages` is enabled |
| Compaction | `SystemMessage` (subtype `"compact_boundary"`) | `"system"` (subtype `"compact_boundary"`) | After context compaction |
| Final result | `ResultMessage` | `"result"` | Marks end of loop; carries result text, cost, usage |

### Result Subtypes

| Subtype | Meaning | `result` field present? |
|:--------|:--------|:------------------------|
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled request | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All result subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Permission Evaluation Order

1. Hooks (`PreToolUse`) — can deny outright
2. Deny rules (`disallowed_tools` / settings) — blocks even in `bypassPermissions`
3. Permission mode
4. Allow rules (`allowed_tools` / settings)
5. `canUseTool` callback (skipped in `dontAsk` mode)

### Allow / Deny Rule Patterns

| Pattern | Effect |
|:--------|:-------|
| `"Bash"` in `disallowedTools` | Removes `Bash` from Claude's tool context entirely |
| `"Bash(rm *)"` in `disallowedTools` | Keeps `Bash` available; blocks calls matching `rm *` in all modes |
| `"Read"` in `allowedTools` | Auto-approves `Read`; unlisted tools fall through to permission mode |
| `"mcp__server__*"` in `allowedTools` | Wildcard: auto-approves all tools from an MCP server |

### Hooks — Available Events

| Event | When it fires | Can block? |
|:------|:-------------|:-----------|
| `PreToolUse` | Before a tool executes | Yes |
| `PostToolUse` | After a tool returns | No (can inject feedback) |
| `PostToolUseFailure` | After a tool fails | No |
| `PostToolBatch` | After full batch of parallel tool calls | Yes |
| `UserPromptSubmit` | When a prompt is sent | Yes |
| `SessionStart` | Session begins | No |
| `SessionEnd` | Session terminates | No |
| `Stop` | Agent finishes | Yes |
| `SubagentStart` | Subagent spawns | No |
| `SubagentStop` | Subagent completes | Yes |
| `PreCompact` | Before context compaction | Yes |
| `PermissionRequest` | Permission dialog about to appear | Yes |
| `Notification` | Agent sends a notification | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `TaskCompleted` | Task marked completed | Yes |
| `ConfigChange` | Config file changes mid-session | Yes |
| `WorktreeCreate` | Worktree being created | Yes |
| `WorktreeRemove` | Worktree being removed | No |
| `MessageDisplay` | Assistant message text streams | No |
| `Setup` | `--init-only` mode | No |

### Hooks — Callback Signature

**Python:**
```python
async def my_hook(input_data: dict, tool_use_id: str | None, context) -> dict:
    return {}  # empty = allow; set hookSpecificOutput to control behavior
```

**TypeScript:**
```typescript
const myHook: HookCallback = async (input, toolUseId, options) => {
    return {};  // empty = allow
};
```

Register hooks in `options.hooks` as `{ EventName: [{ matcher?: "ToolName", hooks: [callback] }] }`.

### MCP Server Config Types

| Type | When to use | Key fields |
|:-----|:-----------|:-----------|
| `stdio` | Local subprocess | `command`, `args?`, `env?` |
| `sse` | Remote SSE endpoint | `type: "sse"`, `url`, `headers?` |
| `http` | Remote HTTP endpoint | `type: "http"`, `url`, `headers?` |
| `sdk` | In-process MCP server | Created via `createSdkMcpServer()` / `create_sdk_mcp_server()` |

MCP tool names follow the pattern `mcp__<server-name>__<tool-name>`.

### Custom Tools (In-process MCP)

**Python** — use `@tool` decorator then `create_sdk_mcp_server()`:
```python
@tool("name", "description", {"param": str})
async def my_tool(args):
    return {"content": [{"type": "text", "text": "result"}]}

server = create_sdk_mcp_server(name="my-server", tools=[my_tool])
options = ClaudeAgentOptions(mcp_servers={"my": server})
```

**TypeScript** — use `tool()` helper then `createSdkMcpServer()`:
```typescript
const myTool = tool("name", "description", { param: z.string() },
    async ({ param }) => ({ content: [{ type: "text", text: "result" }] })
);
const server = createSdkMcpServer({ name: "my-server", tools: [myTool] });
```

Set `readOnlyHint: true` on tools with no side effects to enable parallel execution.

### Sessions

| Approach | Python | TypeScript | When to use |
|:---------|:-------|:-----------|:------------|
| Single call | `query()` | `query()` | One-off tasks |
| Multi-turn in one process | `ClaudeSDKClient` | `continue: true` | Conversational apps |
| Continue most recent | `continue_conversation=True` | `continue: true` | Resume after restart |
| Resume specific session | `resume="<session-id>"` | `resume: "<session-id>"` | Named session management |
| Fork (branch) | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Try alternate approach |
| Disable persistence | (always persists) | `persistSession: false` | Stateless/ephemeral |

Capture the session ID from `ResultMessage.session_id` (Python) or the init `SystemMessage.session_id` (TypeScript) to resume later.

### `AgentDefinition` Fields (Subagents)

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When Claude should invoke this agent |
| `prompt` | Yes | Agent's system prompt |
| `tools` | No | Allowed tools (omit to inherit parent's tools) |
| `disallowedTools` | No | Explicitly blocked tools |
| `model` | No | Model override (`'sonnet'`, `'opus'`, `'haiku'`, `'inherit'`, or full ID) |
| `maxTurns` | No | Turn cap for this agent |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Reasoning effort level |
| `permissionMode` | No | Permission mode for this agent |
| `skills` | No | Skill names to preload |
| `memory` | No | `'user'`, `'project'`, or `'local'` |

Add `"Agent"` to `allowedTools` to auto-approve subagent invocations.

### `SettingSource` Values

| Value | Location |
|:------|:---------|
| `'user'` | `~/.claude/settings.json` |
| `'project'` | `.claude/settings.json` |
| `'local'` | `.claude/settings.local.json` |

Pass `setting_sources=[]` (Python) or `settingSources: []` (TypeScript) to isolate agents from local config. Managed policy settings load regardless.

### Python `ClaudeSDKClient` vs `query()`

| Feature | `query()` | `ClaudeSDKClient` |
|:--------|:----------|:------------------|
| Session continuity | Manual via `resume` | Automatic |
| Interrupts | No | Yes (`interrupt()`) |
| Multi-turn in one process | No | Yes |
| One-off tasks | Yes | Overkill |

### TypeScript `Query` object — Key Methods

| Method | Description |
|:-------|:------------|
| `interrupt()` | Stop the running query (streaming input mode only) |
| `rewindFiles(userMessageId)` | Restore files to state at that message (requires `enableFileCheckpointing`) |
| `setPermissionMode(mode)` | Change permission mode mid-session |
| `setModel(model)` | Change model mid-session |
| `applyFlagSettings(settings)` | Merge settings into flag layer mid-session |
| `mcpServerStatus()` | Status of connected MCP servers |
| `setMcpServers(servers)` | Dynamically replace MCP servers |
| `streamInput(stream)` | Send streamed input messages |
| `close()` | Terminate the underlying process |

### Cost and Usage

`ResultMessage` fields: `total_cost_usd` (client-side estimate), `usage` (token counts), `model_usage` / `modelUsage` (per-model breakdown), `num_turns`, `duration_ms`.

`total_cost_usd` is a local estimate, not authoritative billing. Use the Anthropic Usage and Cost API or Console for billing.

### Structured Outputs

Pass `output_format={"type": "json_schema", "schema": {...}}` (Python) or `outputFormat: { type: 'json_schema', schema: {...} }` (TypeScript). The result appears in `ResultMessage.structured_output` on success. If validation fails after retries, result subtype is `error_max_structured_output_retries`.

### Session Storage (External Backends)

Implement the `SessionStore` interface and pass it as `session_store` / `sessionStore` to mirror transcripts to an external backend (database, object store). Required for resuming sessions across hosts or container restarts.

### Hosting Patterns

| Pattern | Container lifetime | Best for |
|:--------|:------------------|:---------|
| Ephemeral | One container per task | One-off tasks |
| Persistent | Container lives across sessions | Multi-turn apps, user sessions |
| Serverless | Spin up on demand | Bursty workloads |
| Kubernetes | Managed orchestration | Scale-out production |

Sessions live on local disk by default; configure `SessionStore` for cross-host persistence.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — Introduction, capabilities, comparison to CLI and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build and run your first agent end-to-end
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, context window, compaction, result handling
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete API: `query()`, `Options`, all message types, hook types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; session IDs; multi-turn patterns
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — External storage backends via `SessionStore` interface
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, evaluation order
- [Hooks](references/claude-code-agent-sdk-hooks.md) — All hook events, callback API, matchers, common patterns
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — Define tools with `@tool`/`tool()`, in-process MCP servers
- [MCP](references/claude-code-agent-sdk-mcp.md) — Connect external MCP servers, tool search, transports, auth
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Programmatic and filesystem-based subagent definitions, parallelism
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — CLAUDE.md, skills, commands, memory via `settingSources`
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom system prompts, preset, append, output styles
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Real-time token streaming with `includePartialMessages`
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use streaming input vs one-shot mode
- [User Input](references/claude-code-agent-sdk-user-input.md) — Interactive approvals, `canUseTool` callback, `AskUserQuestion`
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON schema output validation
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage, cost fields, prompt caching
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, metrics, debugging
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and rewind file changes
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — Task tracking within agent sessions
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Lazy-load tools on demand for large tool sets
- [Skills](references/claude-code-agent-sdk-skills.md) — Use skills in SDK sessions
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Send commands like `/compact` in SDK sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Load plugins programmatically via `plugins` option
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Docker, Kubernetes, sandbox, multi-tenant deployment
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Network controls, credential management, isolation
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from older SDK versions
- [TypeScript v2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Upcoming TypeScript SDK v2 changes

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
- TypeScript v2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
