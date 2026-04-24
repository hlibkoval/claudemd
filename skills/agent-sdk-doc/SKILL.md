---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (TypeScript package `@anthropic-ai/claude-agent-sdk`, Python package `claude-agent-sdk`).

## Quick Reference

### Installation

| Language   | Package                              | Command                                      |
|------------|--------------------------------------|----------------------------------------------|
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`               |

> Note: The old package names were `@anthropic-ai/claude-code` (TS) and `claude-code-sdk` (Python). See migration guide for upgrade steps.

### Core Entry Point

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({ prompt: "...", options: { model: "claude-opus-4-7" } })) {
  if (message.type === "result" && message.subtype === "success") {
    console.log(message.result);
  }
}
```

```python
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async for message in query(prompt="...", options=ClaudeAgentOptions(model="claude-opus-4-7")):
    if isinstance(message, ResultMessage) and message.subtype == "success":
        print(message.result)
```

### Message Types

| Type              | Subtype / Notes                                                   |
|-------------------|-------------------------------------------------------------------|
| `system`          | `init` (session start) or `compact_boundary` (context compacted) |
| `assistant`       | Contains `message.content` blocks (text, tool_use, etc.)         |
| `user`            | Tool results fed back to the model                                |
| `result`          | Final message — check `subtype` for success/error                 |

### Result Subtypes

| Subtype                               | Meaning                                              |
|---------------------------------------|------------------------------------------------------|
| `success`                             | Task completed; `result` field has the output        |
| `error_max_turns`                     | Hit the `maxTurns` limit                             |
| `error_max_budget_usd`                | Hit the `maxBudgetUsd` cost limit                    |
| `error_during_execution`              | Runtime error; `error` field has details             |
| `error_max_structured_output_retries` | Structured output validation failed after retries    |

### Key `query()` Options (ClaudeAgentOptions / ClaudeCodeOptions)

| Option                  | Type             | Description                                                              |
|-------------------------|------------------|--------------------------------------------------------------------------|
| `model`                 | string           | Model to use (e.g. `claude-opus-4-7`, `claude-sonnet-4-5`)              |
| `maxTurns`              | number           | Max agent loop iterations                                                |
| `maxBudgetUsd`          | number           | Cost ceiling in USD                                                      |
| `systemPrompt`          | string/object    | Override system prompt (see Modifying System Prompts)                    |
| `allowedTools`          | string[]         | Tools the agent may use; supports `mcp__server__*` wildcards             |
| `disallowedTools`       | string[]         | Tools the agent must never use                                           |
| `permissionMode`        | string           | `default`, `acceptEdits`, `plan`, `dontAsk`, `auto`, `bypassPermissions` |
| `mcpServers`            | object           | Named MCP server configs (stdio, http, sse)                              |
| `hooks`                 | object           | Event-based lifecycle hooks                                              |
| `outputFormat`          | object           | Structured output schema (JSON Schema / Zod / Pydantic)                 |
| `settingSources`        | string[]         | Which sources to load: `"project"`, `"user"`, `"local"`                 |
| `agents`                | AgentDefinition[]| Subagent definitions                                                     |
| `env`                   | object           | Environment variables for the agent process                              |
| `continue`              | bool (TS)        | Continue the most recent session                                         |
| `resume`                | string (TS)      | Resume a session by ID                                                   |

### Permission Modes

| Mode               | Behavior                                                         |
|--------------------|------------------------------------------------------------------|
| `default`          | Prompts for approval on risky tools                              |
| `acceptEdits`      | Auto-approves file edits; prompts for other actions              |
| `plan`             | Read-only; no writes or commands                                 |
| `dontAsk`          | Never prompts user; uses allow/deny rules silently               |
| `auto`             | Autonomous mode; approves everything (TS only)                   |
| `bypassPermissions`| Skips all permission checks (use with caution)                   |

### Permission Evaluation Order

1. Hooks (can allow/deny/ask/defer)
2. Deny rules (always block)
3. Permission mode (interactive check)
4. Allow rules (pre-approved patterns)
5. `canUseTool` callback (custom logic)

### Built-in Tools

| Tool              | Description                                           |
|-------------------|-------------------------------------------------------|
| `Read`            | Read file contents                                    |
| `Write`           | Write file contents                                   |
| `Edit`            | Make targeted file edits                              |
| `Bash`            | Run shell commands                                    |
| `Monitor`         | Stream events from a background process               |
| `Glob`            | Find files by pattern                                 |
| `Grep`            | Search file contents                                  |
| `WebSearch`       | Search the web                                        |
| `WebFetch`        | Fetch a URL                                           |
| `AskUserQuestion` | Ask the user an interactive question                  |
| `TodoWrite`       | Manage task list                                      |
| `ToolSearch`      | Search for tools dynamically                          |
| `Skill`           | Invoke an agent skill                                 |
| `Agent`           | Spawn a subagent                                      |

### Custom Tools

Define a tool (TypeScript):
```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";

const myTool = tool({
  name: "my_tool",
  description: "Does something useful",
  inputSchema: { type: "object", properties: { x: { type: "string" } }, required: ["x"] },
  handler: async ({ x }) => `Result: ${x}`
});

const server = createSdkMcpServer({ name: "my-server", tools: [myTool] });
```

Define a tool (Python):
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool(name="my_tool", description="Does something useful")
async def my_tool(x: str) -> str:
    return f"Result: {x}"

server = create_sdk_mcp_server(name="my-server", tools=[my_tool])
```

Tool name format when used in `allowedTools`: `mcp__{server_name}__{tool_name}`

### Sessions

| Method / Option       | Description                                                        |
|-----------------------|--------------------------------------------------------------------|
| `continue: true` (TS) | Continue the most recent session in the current directory          |
| `resume: <id>` (TS)   | Resume a specific session by ID                                    |
| `ClaudeSDKClient` (Py)| Python client class supporting `continue_session` / `resume`       |
| Fork (TS V1 only)     | `forkSession` option — creates a new branch from a session         |

Session data is stored at `~/.claude/projects/<encoded-cwd>/*.jsonl`.

### Subagents

```typescript
options: {
  agents: [{
    description: "Summarizer",
    prompt: "Summarize the given text",
    tools: ["Read"],
    model: "claude-sonnet-4-5",
    maxTurns: 5,
    background: false,
    permissionMode: "plan"
  }],
  allowedTools: ["Agent"]
}
```

Key `AgentDefinition` fields: `description`, `prompt`, `tools`, `disallowedTools`, `model`, `skills`, `memory`, `mcpServers`, `maxTurns`, `background`, `effort`, `permissionMode`.

### Hooks

Hooks intercept agent lifecycle events. Configure via `hooks` option in `query()`. Each hook entry has:
- `matcher`: `HookMatcher` with optional `tool_name` regex
- `handler`: function receiving event + context, returning optional `hookSpecificOutput`

Key `hookSpecificOutput` field: `permissionDecision` — `"allow"`, `"deny"`, `"ask"`, or `"defer"`.

Common hook event types:

| Event Type                       | Trigger                                       |
|----------------------------------|-----------------------------------------------|
| `PreToolUse`                     | Before a tool runs                            |
| `PostToolUse`                    | After a tool completes                        |
| `UserPromptSubmit`               | When user submits a prompt                    |
| `AssistantResponse`              | When assistant produces a response            |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle                            |
| `SessionStart` / `SessionStop`   | Session boundaries                            |

### System Prompt Options

| Value                                      | Effect                                                  |
|--------------------------------------------|---------------------------------------------------------|
| `"minimal"` (default)                      | Minimal system prompt                                   |
| `{type: "preset", preset: "claude_code"}`  | Full Claude Code system prompt                          |
| `{type: "preset", ..., append: "..."}`     | Preset + appended text                                  |
| Custom string                              | Fully custom system prompt                              |
| `excludeDynamicSections: true`             | Removes per-session dynamic parts for cache sharing     |

### Structured Outputs

```typescript
options: {
  outputFormat: {
    type: "json_schema",
    schema: { type: "object", properties: { answer: { type: "string" } } }
  }
}
```

Python: pass a Pydantic model class. TypeScript: pass a Zod schema. The result is validated; failures retry up to a limit (`error_max_structured_output_retries`).

### settingSources

Controls which config sources the agent loads:

| Source      | Loads                                           |
|-------------|-------------------------------------------------|
| `"project"` | `CLAUDE.md`, project skills, project hooks      |
| `"user"`    | User-level settings, user hooks                 |
| `"local"`   | Local settings (`.claude/settings.local.json`)  |

Default: all three. Pass an empty array to disable all config loading.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` to emit spans. Key span names:
- `claude_code.interaction` — full agent run
- `claude_code.llm_request` — individual LLM API calls
- `claude_code.tool` — tool executions
- `claude_code.hook` — hook invocations

### Tool Search

Controls how tool definitions are loaded into context:

| `ENABLE_TOOL_SEARCH` | Behavior                                                                    |
|----------------------|-----------------------------------------------------------------------------|
| unset / `true`       | Always on — tool defs never loaded upfront; searched on demand              |
| `auto`               | Activates when tool defs exceed 10% of context window                       |
| `auto:N`             | Activates at custom threshold N%                                             |
| `false`              | Off — all tool defs loaded upfront on every turn                            |

Max 10,000 tools in catalog. Requires Claude Sonnet 4+ or Opus 4+ (no Haiku).

### File Checkpointing

```typescript
options: {
  enableFileCheckpointing: true,
  extraArgs: { "replay-user-messages": null }
}
```

Call `rewindFiles(sessionId)` to restore files to a prior state. Tracks Write, Edit, and NotebookEdit operations.

### Cost Tracking

`ResultMessage` contains `costUsd` (total cost). `StreamEvent` messages include per-turn cost data. Use `maxBudgetUsd` to cap spending.

### TypeScript V2 (Unstable Preview)

```typescript
import { unstable_v2_createSession } from "@anthropic-ai/claude-agent-sdk";

await using session = unstable_v2_createSession({ model: "claude-opus-4-7" });
await session.send("Hello!");
for await (const msg of session.stream()) {
  if (msg.type === "assistant") { /* handle */ }
}
```

V2 key functions: `unstable_v2_createSession()`, `unstable_v2_resumeSession(sessionId, opts)`, `unstable_v2_prompt(prompt, opts)`.

V2 `SDKSession` interface: `sessionId`, `send(message)`, `stream()`, `close()`.

Note: session forking is V1 only.

### Migration from Old Package Names

| Old (deprecated)                | New                               |
|---------------------------------|-----------------------------------|
| `@anthropic-ai/claude-code`     | `@anthropic-ai/claude-agent-sdk`  |
| `claude-code-sdk`               | `claude-agent-sdk`                |
| `ClaudeCodeOptions`             | `ClaudeAgentOptions`              |
| `claude-code` binary reference  | bundled binary (no separate install needed) |

### User Input (Interactive)

Use `AskUserQuestion` tool to pause and ask the user a question mid-execution. The response is returned as a tool result and execution continues. Requires interactive mode (not available in non-interactive/headless contexts without a user input handler).

### Streaming vs Single Mode

- **Streaming** (`query()` async iterator): Receives message events as they occur; lower latency, more complex handling.
- **Single mode**: Waits for full completion before returning. Use when you only need the final result.

### MCP Server Configuration

```typescript
options: {
  mcpServers: {
    "my-server": { type: "stdio", command: "node", args: ["server.js"] },
    "remote":    { type: "http", url: "https://tools.example.com/mcp" },
    "legacy":    { type: "sse",  url: "https://tools.example.com/sse" }
  }
}
```

### Plugins in the SDK

```typescript
options: {
  plugins: ["my-plugin"]  // load by name
}
```

Plugins provide skills, tools, and hooks. Same plugin format as Claude Code CLI plugins.

### Hosting / Deployment

- **Local**: Runs Claude Code binary bundled with the SDK package.
- **Remote / serverless**: Use `ANTHROPIC_API_KEY` env var. The SDK manages subprocess lifecycle.
- Use `settingSources: []` in CI/CD to prevent loading local user config.
- For multi-tenant hosting, use `bypassPermissions` or `dontAsk` with strict `allowedTools`/`disallowedTools`.

### Secure Deployment

- Never expose raw agent capabilities to untrusted input without sandboxing.
- Use `permissionMode: "plan"` for read-only analysis tasks.
- Use `disallowedTools` to block dangerous tools (e.g. `Bash`) in restricted environments.
- Use `settingSources: []` to prevent user config injection.
- Use hooks with `permissionDecision: "deny"` to block specific tool patterns.

---

## Full Documentation

- [Overview](references/claude-code-agent-sdk-overview.md) — What the SDK is, use cases, architecture
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Installation, first query, basic patterns
- [Agent Loop](references/claude-code-agent-sdk-agent-loop.md) — How the agent loop works, message flow, turn mechanics
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Which Claude Code CLI features are available via SDK
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Tracking API costs, `costUsd`, `maxBudgetUsd`
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — `@tool` / `tool()`, `createSdkMcpServer`, tool naming
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — `enableFileCheckpointing`, `rewindFiles()`
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Lifecycle hooks, event types, `permissionDecision`
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Deployment patterns, environment setup
- [MCP Servers](references/claude-code-agent-sdk-mcp.md) — Connecting MCP servers (stdio, http, sse)
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from old package names
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Preset, append, custom, excludeDynamicSections
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry spans, `CLAUDE_CODE_ENABLE_TELEMETRY`
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, evaluation order
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Using plugins with the SDK
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Full Python API reference
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Security hardening for production use
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; session storage
- [Skills](references/claude-code-agent-sdk-skills.md) — Loading and using agent skills
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Slash command support via SDK
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — StreamEvent message types, streaming patterns
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use each approach
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema / Zod / Pydantic output schemas
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `agents` option, `AgentDefinition` fields
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool, monitoring todo state
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — `ENABLE_TOOL_SEARCH` env var, large tool catalogs
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Full TypeScript API reference
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — `unstable_v2_createSession`, session-based API
- [User Input](references/claude-code-agent-sdk-user-input.md) — `AskUserQuestion` tool, interactive prompting

---

## Sources

- https://code.claude.com/docs/en/agent-sdk/overview.md
- https://code.claude.com/docs/en/agent-sdk/quickstart.md
- https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- https://code.claude.com/docs/en/agent-sdk/hooks.md
- https://code.claude.com/docs/en/agent-sdk/hosting.md
- https://code.claude.com/docs/en/agent-sdk/mcp.md
- https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- https://code.claude.com/docs/en/agent-sdk/observability.md
- https://code.claude.com/docs/en/agent-sdk/permissions.md
- https://code.claude.com/docs/en/agent-sdk/plugins.md
- https://code.claude.com/docs/en/agent-sdk/python.md
- https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- https://code.claude.com/docs/en/agent-sdk/sessions.md
- https://code.claude.com/docs/en/agent-sdk/skills.md
- https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- https://code.claude.com/docs/en/agent-sdk/subagents.md
- https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- https://code.claude.com/docs/en/agent-sdk/tool-search.md
- https://code.claude.com/docs/en/agent-sdk/typescript.md
- https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- https://code.claude.com/docs/en/agent-sdk/user-input.md
