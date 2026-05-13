---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — programmatic AI agents in Python and TypeScript. Covers the query() API, agent loop, sessions, hooks, permissions, subagents, MCP servers, custom tools, structured outputs, streaming, cost tracking, hosting, and secure deployment.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly the Claude Code SDK).

## Quick Reference

### Installation

| Language   | Package                              | Install                                    |
| :--------- | :----------------------------------- | :----------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`             |

The TypeScript SDK bundles a native Claude Code binary; no separate CLI install is needed.

### Migration Note

The SDK was renamed from the Claude Code SDK. Old packages:

| Language   | Old package                    | New package                          |
| :--------- | :----------------------------- | :----------------------------------- |
| TypeScript | `@anthropic-ai/claude-code`    | `@anthropic-ai/claude-agent-sdk`     |
| Python     | `claude-code-sdk`              | `claude-agent-sdk`                   |

### Authentication

Set `ANTHROPIC_API_KEY` or use a third-party provider:

| Provider             | Environment variable(s)                                           |
| :------------------- | :---------------------------------------------------------------- |
| Anthropic (default)  | `ANTHROPIC_API_KEY`                                               |
| Amazon Bedrock       | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials                     |
| Claude Platform/AWS  | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI     | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials                      |
| Microsoft Azure      | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials                   |

### Core API: `query()`

The primary function. Returns an async iterator of messages.

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

**TypeScript:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

### Built-in Tools

| Tool              | What it does                                            |
| :---------------- | :------------------------------------------------------ |
| `Read`            | Read any file in the working directory                  |
| `Write`           | Create new files                                        |
| `Edit`            | Make precise edits to existing files                    |
| `Bash`            | Run terminal commands, scripts, git operations          |
| `Monitor`         | Watch a background script; react to each output line   |
| `Glob`            | Find files by pattern (`**/*.ts`, `src/**/*.py`)        |
| `Grep`            | Search file contents with regex                         |
| `WebSearch`       | Search the web for current information                  |
| `WebFetch`        | Fetch and parse web page content                        |
| `ToolSearch`      | Dynamically find and load tools on demand               |
| `Agent`           | Spawn subagents for isolated subtasks                   |
| `Skill`           | Invoke a loaded skill                                   |
| `AskUserQuestion` | Ask the user clarifying questions with multiple choices |
| `TodoWrite`       | Track tasks within a session                            |

### Key Options (`ClaudeAgentOptions` / `Options`)

| Python field           | TypeScript field       | Description                                               |
| :--------------------- | :--------------------- | :-------------------------------------------------------- |
| `allowed_tools`        | `allowedTools`         | Pre-approved tools (auto-approved, no prompts)            |
| `disallowed_tools`     | `disallowedTools`      | Always-denied tools (even in bypassPermissions mode)      |
| `permission_mode`      | `permissionMode`       | Global permission behavior (see table below)              |
| `system_prompt`        | `systemPrompt`         | Custom system prompt                                      |
| `mcp_servers`          | `mcpServers`           | External MCP server configs                               |
| `agents`               | `agents`               | Named subagent definitions                                |
| `hooks`                | `hooks`                | SDK callback hooks                                        |
| `max_turns`            | `maxTurns`             | Max tool-use rounds before stopping                       |
| `max_budget_usd`       | `maxBudgetUsd`         | Cost cap in USD                                           |
| `effort`               | `effort`               | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model`                | `model`                | Model ID (e.g., `"claude-sonnet-4-6"`)                    |
| `resume`               | `resume`               | Session ID to resume                                      |
| `fork_session`         | `forkSession`          | Fork instead of resuming in place                         |
| `continue_conversation`| `continue`             | Resume the most recent session in the current directory   |
| `setting_sources`      | `settingSources`       | Which config sources to load: `"project"`, `"user"`, etc. |
| `cwd`                  | `cwd`                  | Working directory for the agent                           |
| `include_partial_messages` | `includePartialMessages` | Enable real-time streaming output               |
| `structured_output`    | `structuredOutput`     | JSON Schema / Zod / Pydantic for typed output             |
| `tools`                | `tools`                | Limit built-in tools in Claude's context                  |
| `persist_session`      | `persistSession`       | TypeScript only: set `false` to skip disk persistence     |

### Permission Modes

| Mode                | Behavior                                                                          |
| :------------------ | :-------------------------------------------------------------------------------- |
| `default`           | Unmatched tools call `canUseTool` callback; no callback = deny                   |
| `acceptEdits`       | Auto-approves file edits and filesystem commands (`mkdir`, `mv`, `rm`, `cp`, etc.) |
| `dontAsk`           | Anything not pre-approved is denied; never calls `canUseTool`                    |
| `plan`              | Read-only tools only; Claude can explore and plan without modifying files         |
| `auto` (TS only)    | Model classifier approves or denies each tool call                                |
| `bypassPermissions` | All tools run without prompts — use only in sandboxed/trusted environments        |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool`

### Message Types

| Python class          | TypeScript `type` field    | When emitted                                           |
| :-------------------- | :------------------------- | :----------------------------------------------------- |
| `SystemMessage`       | `"system"`                 | Session init (`subtype: "init"`) and compaction events |
| `AssistantMessage`    | `"assistant"`              | After each Claude response (text + tool calls)         |
| `UserMessage`         | `"user"`                   | After each tool execution with results                 |
| `StreamEvent`         | `"stream_event"`           | Per-token streaming events (when partial messages on)  |
| `ResultMessage`       | `"result"`                 | Loop end; includes `result`, `session_id`, cost, usage |

**ResultMessage subtypes:**

| Subtype                             | Meaning                                         |
| :---------------------------------- | :---------------------------------------------- |
| `success`                           | Task completed; `result` field has final text   |
| `error_max_turns`                   | Hit `maxTurns` limit                            |
| `error_max_budget_usd`              | Hit `maxBudgetUsd` limit                        |
| `error_during_execution`            | API or execution error                          |
| `error_max_structured_output_retries` | Structured output validation failed           |

### Sessions

| Approach                     | Python                             | TypeScript                    |
| :--------------------------- | :--------------------------------- | :---------------------------- |
| Capture session ID           | `ResultMessage.session_id`         | `message.session_id` on result |
| Resume specific session      | `ClaudeAgentOptions(resume=id)`    | `options: { resume: id }`     |
| Continue most recent session | `continue_conversation=True`       | `options: { continue: true }` |
| Fork a session               | `resume=id, fork_session=True`     | `resume: id, forkSession: true` |
| Multi-turn client (Python)   | `ClaudeSDKClient` context manager  | n/a (use `continue: true`)    |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.

**Python `ClaudeSDKClient`** — manages session IDs automatically across multiple `client.query()` calls:
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("Analyze the auth module")
    async for msg in client.receive_response():
        print(msg)
    await client.query("Now refactor it")   # same session, full context
    async for msg in client.receive_response():
        print(msg)
```

### Hooks (SDK Callbacks)

Register callback functions in `ClaudeAgentOptions(hooks={...})`.

**Available hook events:**

| Event                | Python | TypeScript | Trigger                                          |
| :------------------- | :----: | :--------: | :----------------------------------------------- |
| `PreToolUse`         | Yes    | Yes        | Before a tool executes (can block/modify)         |
| `PostToolUse`        | Yes    | Yes        | After a tool returns                              |
| `PostToolUseFailure` | Yes    | Yes        | After a tool fails                                |
| `PostToolBatch`      | No     | Yes        | Full batch of parallel tool calls resolves        |
| `UserPromptSubmit`   | Yes    | Yes        | When a prompt is sent                             |
| `Stop`               | Yes    | Yes        | Agent execution ends                              |
| `SubagentStart`      | Yes    | Yes        | Subagent initializes                              |
| `SubagentStop`       | Yes    | Yes        | Subagent completes                                |
| `PreCompact`         | Yes    | Yes        | Before context compaction                         |
| `PermissionRequest`  | Yes    | Yes        | Permission dialog would show                      |
| `Notification`       | Yes    | Yes        | Agent status messages                             |
| `SessionStart`       | No     | Yes        | Session initializes                               |
| `SessionEnd`         | No     | Yes        | Session terminates                                |
| `TeammateIdle`       | No     | Yes        | Teammate becomes idle                             |
| `TaskCompleted`      | No     | Yes        | Background task completes                         |
| `ConfigChange`       | No     | Yes        | Config file changes                               |
| `WorktreeCreate`     | No     | Yes        | Git worktree created                              |
| `WorktreeRemove`     | No     | Yes        | Git worktree removed                              |

**Hook registration (Python):**
```python
ClaudeAgentOptions(hooks={
    "PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])]
})
```

**Callback signature:**
- Python: `async def callback(input_data, tool_use_id, context) -> dict`
- TypeScript: `async (input, toolUseId, { signal }) => object`

**Callback outputs:**

| Field                                | Description                                               |
| :----------------------------------- | :-------------------------------------------------------- |
| `systemMessage`                      | Injects a message into the conversation                   |
| `continue` (`continue_` in Python)   | If `false`, stops the agent                               |
| `hookSpecificOutput.permissionDecision` | `"allow"`, `"deny"`, `"ask"`, or `"defer"` (PreToolUse) |
| `hookSpecificOutput.updatedInput`    | Modified tool input (PreToolUse, requires `allow`/`ask`)  |
| `hookSpecificOutput.additionalContext` | Appended to tool result (PostToolUse)                   |
| `async: true`                        | Return immediately, run side-effect in background         |

**Priority when multiple hooks:** deny > defer > ask > allow.

### Subagents

Define subagents via the `agents` option. Must include `"Agent"` in `allowedTools`.

**`AgentDefinition` fields:**

| Field           | Required | Description                                                            |
| :-------------- | :------- | :--------------------------------------------------------------------- |
| `description`   | Yes      | When Claude should use this agent (used for auto-routing)              |
| `prompt`        | Yes      | System prompt for the subagent                                         |
| `tools`         | No       | Subset of allowed tools; inherits all if omitted                       |
| `disallowedTools` | No     | Tools to block for this subagent                                       |
| `model`         | No       | Model alias: `"sonnet"`, `"opus"`, `"haiku"`, or full model ID         |
| `maxTurns`      | No       | Max turns for this subagent                                            |
| `background`    | No       | `true` = run as non-blocking background task                           |
| `effort`        | No       | Reasoning effort override for this subagent                            |
| `permissionMode`| No       | Permission mode override for this subagent                             |
| `skills`        | No       | Skills to preload into the subagent's context                          |
| `mcpServers`    | No       | MCP servers available to this subagent                                 |

Subagents cannot spawn their own subagents. Do not include `"Agent"` in a subagent's `tools`.

### MCP Servers

Configure external MCP servers in `mcpServers`. Tool names follow the pattern `mcp__<server>__<tool>`.

**Transport types:**

| Type      | Config key        | Use for                                        |
| :-------- | :---------------- | :--------------------------------------------- |
| `stdio`   | `command`, `args` | Local processes (e.g., `npx @modelcontextprotocol/server-github`) |
| `http`    | `type: "http"`, `url` | HTTP/streamable-HTTP remote servers        |
| `sse`     | `type: "sse"`, `url` | Server-Sent Events remote servers           |
| SDK MCP   | `createSdkMcpServer` / `create_sdk_mcp_server` | In-process custom tools |

Use `allowedTools: ["mcp__myserver__*"]` to permit all tools from a server (wildcards supported).

### Custom Tools (In-Process MCP)

**TypeScript:** use `tool()` + `createSdkMcpServer()`
**Python:** use `@tool` decorator + `create_sdk_mcp_server()`

Tool handler return shape:
```typescript
{ content: [{ type: "text", text: "..." }], isError?: true, structuredContent?: {...} }
```

- Throw = agent loop stops. Return `isError: true` = Claude sees the error and can retry.
- Set `readOnlyHint: true` in annotations to enable parallel execution.
- Python `@tool` does not forward `structuredContent`; use a standalone MCP server for that.

### Structured Outputs

Pass a JSON Schema / Zod / Pydantic schema as `structured_output` / `structuredOutput`. The SDK validates and re-prompts on mismatch; failure returns `error_max_structured_output_retries`. Streaming (`include_partial_messages`) is incompatible with structured outputs.

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true`. Check for `StreamEvent` / `type: "stream_event"` messages. Key inner event types: `content_block_delta` with `delta.type === "text_delta"` (text) or `delta.type === "input_json_delta"` (tool input). Incompatible with extended thinking (`maxThinkingTokens`).

### Claude Code Features via `settingSources`

When `"project"` is included in `settingSources` (default), the SDK loads:

| Feature         | Location                            | Description                              |
| :-------------- | :---------------------------------- | :--------------------------------------- |
| Memory          | `CLAUDE.md` or `.claude/CLAUDE.md`  | Project context; survives compaction     |
| Skills          | `.claude/skills/*/SKILL.md`         | Specialized capabilities                 |
| Slash commands  | `.claude/commands/*.md`             | Custom commands (send as prompt strings) |
| MCP servers     | `.mcp.json`                         | MCP config file at project root          |
| Subagents       | `.claude/agents/*.md`               | Filesystem-defined subagents             |

### Cost Tracking

Read from `ResultMessage`: `total_cost_usd` (Python) / `costUSD` (TypeScript). These are **client-side estimates** — use the Anthropic Console or Usage API for authoritative billing. Deduplicate per-step usage by message ID when summing manually.

### Hosting Requirements

- Python 3.10+ or Node.js 18+
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production

### TypeScript-only: `startup()` Pre-warming

```typescript
import { startup } from "@anthropic-ai/claude-agent-sdk";
const warm = await startup({ options: { maxTurns: 3 } });
for await (const msg of warm.query("What files are here?")) { ... }
```

Spawns the subprocess early to eliminate cold-start latency on the first query.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK introduction, capabilities summary, comparison with Client SDK / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step first agent, tool combinations, permission mode reference
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — turns/messages lifecycle, context window, compaction, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full API: `query()`, `ClaudeSDKClient`, `@tool`, `create_sdk_mcp_server()`, all types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; cross-host resume
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, callback API, matchers, outputs, examples
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, dynamic mode changes
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, programmatic vs filesystem agents, resuming subagents
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()`/`@tool`, `createSdkMcpServer`, images/resources, error handling
- [MCP servers](references/claude-code-agent-sdk-mcp.md) — transport types, auth, tool search, error handling
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — defer MCP tool schemas, load on demand
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, retry behavior
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — `StreamEvent`, text/tool streaming, UI patterns
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to collect vs stream
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callbacks, `AskUserQuestion`, interactive prompts
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — token usage, per-step deduplication, budgeting
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — CLAUDE.md, skills, commands, plugins via `settingSources`
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `systemPrompt`, memory injection
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, telemetry integration
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — plugin integration for SDK apps
- [Skills](references/claude-code-agent-sdk-skills.md) — loading and using skills from SDK
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — using `/compact` and custom commands as prompt strings
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool integration
- [Subagents (hosting)](references/claude-code-agent-sdk-subagents.md) — parallel, background, resumable subagents
- [Hosting](references/claude-code-agent-sdk-hosting.md) — deployment, container sandboxing, system requirements, sandbox providers
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — experimental V2 session API (deprecated; use V1 `query()`)
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from the old Claude Code SDK package names

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
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
- Streaming vs single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
