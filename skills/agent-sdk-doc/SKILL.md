---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents in Python and TypeScript with the same tools, agent loop, and context management that power Claude Code. Use when working with `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, hooks, subagents, MCP servers, sessions, permissions, custom tools, streaming, structured outputs, cost tracking, hosting, and SDK API references.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — a Python and TypeScript library for building autonomous AI agents that read files, run commands, search the web, edit code, and more.

## Quick Reference

### Installation

| Language | Package | Requires |
| :--- | :--- | :--- |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

The TypeScript SDK bundles a native Claude Code binary as an optional dependency — no separate CLI install needed.

### Minimal usage

```python
# Python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        if hasattr(message, "result"):
            print(message.result)

asyncio.run(main())
```

```typescript
// TypeScript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  if ("result" in message) console.log(message.result);
}
```

### Authentication

| Provider | Environment variable(s) |
| :--- | :--- |
| Anthropic (direct) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1`, `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Built-in tools

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
| `Agent` | Spawn subagents for focused subtasks |
| `Skill` | Invoke skills |
| `TaskCreate` / `TaskUpdate` | Track background tasks |
| `ToolSearch` | Dynamically find and load deferred tool schemas on demand |

### Key `ClaudeAgentOptions` / `Options` fields

| Option (Python / TypeScript) | Type | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `list[str]` / `string[]` | Auto-approve these tools without prompting |
| `disallowed_tools` / `disallowedTools` | `list[str]` / `string[]` | Block these tools; bare name removes from context, scoped rule (`Bash(rm *)`) denies matching calls |
| `permission_mode` / `permissionMode` | `PermissionMode` | Controls what happens to tools not covered by allow/deny rules |
| `system_prompt` / `systemPrompt` | `str` / `string` | Custom system prompt (or preset object for Claude Code's prompt) |
| `max_turns` / `maxTurns` | `int` / `number` | Cap agentic turns (tool-use round trips) |
| `max_budget_usd` / `maxBudgetUsd` | `float` / `number` | Stop when client-side cost estimate reaches this USD value |
| `effort` | `str` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | `str` | Model alias or full ID to use |
| `resume` | `str` | Session ID to resume |
| `continue_conversation` / `continue` | `bool` | Resume the most recent session in the current directory |
| `fork_session` / `forkSession` | `bool` | When resuming, fork to a new session instead of modifying the original |
| `mcp_servers` / `mcpServers` | `dict` / `Record` | MCP server configurations |
| `agents` | `dict` / `Record` | Programmatically defined subagents |
| `hooks` | `dict` / `Record` | Hook callbacks keyed by event name |
| `setting_sources` / `settingSources` | `list` / `array` | Which filesystem sources to load (`"user"`, `"project"`, `"local"`) |
| `cwd` | `str` | Working directory for the agent |
| `skills` | `list` / `string[] \| 'all'` | Skills to load; `'all'` enables every discovered skill |
| `plugins` | `list` / `SdkPluginConfig[]` | Local plugins to load |
| `output_format` / `outputFormat` | object | Structured output schema (JSON Schema) |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `bool` | Track file changes for rewind |
| `session_store` / `sessionStore` | `SessionStore` | Mirror transcripts to external storage |
| `persist_session` / `persistSession` | `bool` | When `false`, disable session persistence to disk (TypeScript only) |

### Permission modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `"default"` | Unlisted tools trigger `canUseTool` callback; no callback means deny | Custom approval flows |
| `"acceptEdits"` | Auto-approves file edits and common filesystem commands | Trusted development workflows |
| `"plan"` | Claude explores and plans; file edits always prompt | Read + plan without writing |
| `"dontAsk"` | Never prompts; tools not pre-approved are denied | Locked-down headless agents |
| `"auto"` (TypeScript only) | Model classifier approves or denies each tool call | Autonomous agents with safety guardrails |
| `"bypassPermissions"` | All allowed tools run without asking; explicit `ask` rules still prompt | Sandboxed CI / fully trusted environments |

### Permission evaluation order

1. **Hooks** — can deny or pass through
2. **Deny rules** (`disallowedTools`) — blocks regardless of mode
3. **Ask rules** (from `settings.json`) — falls through to `canUseTool`
4. **Permission mode** — `bypassPermissions` approves; `acceptEdits` approves file ops
5. **Allow rules** (`allowedTools`) — auto-approves
6. **`canUseTool` callback** — last resort; denied in `dontAsk` mode

### Message types

| Python class | TypeScript `type` field | When emitted |
| :--- | :--- | :--- |
| `SystemMessage` (subtype `"init"`) | `"system"` / `subtype: "init"` | First message; session metadata, tools, model |
| `AssistantMessage` | `"assistant"` | Each Claude response (text + tool calls) |
| `UserMessage` | `"user"` | Tool results fed back to Claude; user stream input |
| `ResultMessage` | `"result"` | End of loop; final text, cost, session ID |
| `StreamEvent` (partial) | `"stream_event"` | Raw streaming deltas (requires `includePartialMessages`) |

### Result subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :---: |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled request | No |
| `error_max_structured_output_retries` | No valid structured output within retry limit | No |

All result subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Session management

| Goal | Python | TypeScript |
| :--- | :--- | :--- |
| Single call, no follow-up | `query()` | `query()` |
| Multi-turn in one process | `ClaudeSDKClient` | `query()` with `continue: true` |
| Resume most recent session | `continue_conversation=True` | `continue: true` |
| Resume a specific session | `resume="<session-id>"` | `resume: "<session-id>"` |
| Fork a session | `fork_session=True` (with `resume`) | `forkSession: true` (with `resume`) |
| List past sessions | `list_sessions()` | `listSessions()` |
| Read past transcript | `get_session_messages()` | `getSessionMessages()` |
| Rename session | `rename_session()` | `renameSession()` |
| Tag session | `tag_session()` | `tagSession()` |

Sessions are stored as JSONL at `~/.claude/projects/<project>/<session-id>.jsonl`. Suppress with `persist_session=False` (TypeScript) or `CLAUDE_CODE_SKIP_PROMPT_HISTORY`.

### Hooks

| Event | Fires when | Common use |
| :--- | :--- | :--- |
| `PreToolUse` | Before a tool executes | Validate inputs, block dangerous commands |
| `PostToolUse` | After a tool returns | Audit outputs, trigger side effects |
| `PostToolUseFailure` | After a tool fails | Error handling |
| `PostToolBatch` | After a batch of tool calls finishes | Aggregate results |
| `UserPromptSubmit` | When a prompt is sent | Inject additional context |
| `Stop` | When the agent finishes | Validate result, save state |
| `SessionStart` / `SessionEnd` | Session lifecycle | Resource management |
| `SubagentStart` / `SubagentStop` | Subagent spawns or completes | Track parallel tasks |
| `PreCompact` | Before context compaction | Archive full transcript |
| `Notification` | Agent sends a notification | Forward to external systems |
| `PermissionRequest` | Permission check required | Custom approval UI |
| `Setup` | Initialization phase | Pre-configure environment |

Hooks are registered in `options.hooks` as a dict/object keyed by event name. Each entry is a list of matchers: `{ matcher: "Write|Edit", hooks: [callback] }`. A bare hook (no matcher) runs for every event of that type.

Hook callbacks return an output object:
- `{}` — allow, no change
- `{ decision: "block", reason: "..." }` — block the tool call (Python: `permissionDecision: "deny"`)
- `{ decision: "approve" }` — explicitly approve
- `{ additionalContext: "..." }` — inject text into the next user message

### Subagents

Define agents in the `agents` option. Claude invokes them via the `Agent` tool — include `"Agent"` in `allowedTools` to auto-approve invocations.

```python
# Python
from claude_agent_sdk import query, ClaudeAgentOptions, AgentDefinition

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Expert code reviewer for quality and security reviews.",
            prompt="Analyze code quality and suggest improvements.",
            tools=["Read", "Glob", "Grep"],
        )
    },
)
```

`AgentDefinition` fields: `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model`, `mcpServers`, `skills`, `maxTurns`, `background`, `effort`, `permissionMode`.

Each subagent runs in a fresh conversation — intermediate tool calls don't accumulate in the parent's context. The parent receives only the subagent's final message.

### MCP servers in the SDK

```python
# Stdio (local process)
mcp_servers={"playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}}

# HTTP
mcp_servers={"api": {"type": "http", "url": "https://mcp.example.com/mcp"}}

# SSE (deprecated)
mcp_servers={"legacy": {"type": "sse", "url": "https://mcp.example.com/sse"}}
```

Use `strict_mcp_config=True` / `strictMcpConfig: true` to ignore project `.mcp.json` and load only the servers you pass programmatically. MCP tool names follow `mcp__<server-name>__<tool-name>`. Use wildcards in `allowedTools`: `"mcp__myserver__*"`.

### Custom tools (in-process MCP servers)

TypeScript: use `tool()` to create a Zod-typed tool definition, then `createSdkMcpServer()` to package it:

```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myTool = tool("lookup", "Look up a value", { key: z.string() },
  async ({ key }) => ({ content: [{ type: "text", text: `value for ${key}` }] })
);
const server = createSdkMcpServer({ name: "my-tools", tools: [myTool] });
// Pass: mcpServers: { "my-tools": server }
```

Python uses `@tool` decorator on async functions and `create_sdk_mcp_server()`.

### Structured outputs

Pass `output_format` / `outputFormat` with a JSON Schema to get schema-constrained results in `ResultMessage.structured_output`:

```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    output_format={
        "type": "json_schema",
        "schema": {
            "type": "object",
            "properties": {"summary": {"type": "string"}, "bugs": {"type": "array"}},
            "required": ["summary", "bugs"]
        }
    }
)
```

### Streaming output

Enable `include_partial_messages=True` / `includePartialMessages: true` to receive `StreamEvent` messages with raw text deltas as Claude generates them.

To collect the full result without streaming, iterate the generator to completion — the `ResultMessage` is the final event.

### Cost tracking

`ResultMessage` fields for cost:
- `total_cost_usd` — client-side USD estimate for the session
- `usage` — `{ input_tokens, output_tokens, cache_creation_input_tokens, cache_read_input_tokens }`
- `modelUsage` — per-model breakdown (TypeScript); `model_usage` (Python)

Set `max_budget_usd` / `maxBudgetUsd` to stop the agent when cost exceeds a threshold.

### File checkpointing

Set `enable_file_checkpointing=True` / `enableFileCheckpointing: true` to track file changes at each user message boundary. Call `query.rewindFiles(userMessageId)` (TypeScript) to restore files to their state at a given point. Pass `{ dryRun: true }` to preview changes before applying.

### Context management tips

- **Automatic compaction** fires when the context window approaches its limit. Emits a `compact_boundary` system message.
- Add a `# Summary instructions` section to `CLAUDE.md` to tell the compactor what to preserve.
- Use subagents for isolated subtasks — they start with a fresh conversation.
- Load `settingSources: ["project"]` to include `CLAUDE.md` instructions without user settings bleeding in.
- Use `effort: "low"` for simple read-only agents to reduce cost and latency.

### Effort levels

| Level | Behavior | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal reasoning | File lookups, listing directories |
| `"medium"` | Balanced | Routine edits, standard tasks |
| `"high"` | Thorough analysis | Refactors, debugging |
| `"xhigh"` | Extended depth | Coding and agentic tasks |
| `"max"` | Maximum depth | Multi-step problems |

### TypeScript `Query` object methods

The object returned by `query()` extends `AsyncGenerator` and exposes:

| Method | Description |
| :--- | :--- |
| `interrupt()` | Interrupt the query (streaming input mode only) |
| `rewindFiles(userMessageId)` | Restore files to a checkpoint |
| `setPermissionMode(mode)` | Change permission mode mid-session |
| `setModel(model)` | Change model mid-session |
| `applyFlagSettings(settings)` | Merge settings into the flag layer at runtime |
| `initializationResult()` | Get full init data (commands, models, agents) |
| `supportedModels()` | List available models |
| `supportedAgents()` | List defined subagents |
| `mcpServerStatus()` | Status of connected MCP servers |
| `setMcpServers(servers)` | Replace MCP server set dynamically |
| `streamInput(stream)` | Send input to a multi-turn conversation |
| `stopTask(taskId)` | Stop a running background task |
| `close()` | Terminate the underlying process |

### Python `ClaudeSDKClient`

For multi-turn conversations within a single process. Each `client.query()` call continues the same session automatically.

```python
async with ClaudeSDKClient(options=ClaudeAgentOptions(allowed_tools=["Read"])) as client:
    await client.query("Analyze auth.py")
    async for msg in client.receive_response():
        ...
    await client.query("Now refactor it")
    async for msg in client.receive_response():
        ...
```

### TypeScript `startup()` — pre-warm subprocess

```typescript
import { startup } from "@anthropic-ai/claude-agent-sdk";

const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) {
  console.log(message);
}
```

Spawns the CLI subprocess early so the first `query()` call has no startup latency.

### Setting sources

| Value | Location | Contains |
| :--- | :--- | :--- |
| `"user"` | `~/.claude/settings.json` | Global user preferences |
| `"project"` | `.claude/settings.json` | Shared project settings, CLAUDE.md |
| `"local"` | `.claude/settings.local.json` | Local-only overrides |

Pass `settingSources: []` to disable all filesystem settings. Managed policy settings load regardless.

### Claude Code filesystem features

When setting sources are enabled (default), the SDK loads:
- `CLAUDE.md` — project instructions injected into every request
- `.claude/skills/` — skills Claude can use
- `.claude/agents/` — subagent definitions
- `.claude/settings.json` — permissions and hooks
- `.mcp.json` — MCP server configuration

### Hosting and deployment

- **Docker**: pass `cwd`, `env`, and `allowedTools` to isolate the working directory. Use `settingSources: []` to ignore local config.
- **CI/CD**: use `permissionMode: "bypassPermissions"` with `allowDangerouslySkipPermissions: true` in trusted sandboxes.
- **Custom subprocess**: set `spawnClaudeCodeProcess` (TypeScript) to run in VMs, containers, or remote environments.

### API timeout env vars

| Variable | Description | Default |
| :--- | :--- | :--- |
| `API_TIMEOUT_MS` | Per-request timeout (ms) | `600000` |
| `CLAUDE_CODE_MAX_RETRIES` | Max API retries | `10` |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | Stall watchdog for background subagents | `600000` |
| `CLAUDE_ENABLE_STREAM_WATCHDOG` | Enable idle stream watchdog | Off by default |
| `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | Stream idle timeout | `300000` |

Pass via `env: { ...process.env, API_TIMEOUT_MS: "120000" }` in TypeScript options.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, built-in tools, capabilities summary, comparison to Client SDK, CLI, and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to building a bug-fixing agent in Python or TypeScript
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, context window, compaction, sessions, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — complete API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, `listSessions()`, `getSessionMessages()`, `resolveSettings()`, all `Options` fields, message types, hook types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — complete API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, message classes, hook types
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, callback signatures, matchers, outputs, per-SDK availability, common patterns
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, evaluation order, `canUseTool` callback
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, `ClaudeSDKClient`, cross-host resumption, `listSessions`, `getSessionMessages`
- [Subagents](references/claude-code-agent-sdk-subagents.md) — defining subagents programmatically and via files, parallelization, context isolation, `AgentDefinition`
- [MCP servers](references/claude-code-agent-sdk-mcp.md) — transport types, `mcpServers` config, tool naming, tool search, authentication, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — in-process MCP servers, `tool()`, `createSdkMcpServer()`, annotations, parallel execution
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — partial messages, text deltas, `includePartialMessages`
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to stream vs. collect all at once
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — `outputFormat` / `output_format`, JSON Schema constraints
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage`, `modelUsage`, `maxBudgetUsd`
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — `enableFileCheckpointing`, `rewindFiles()`, dry-run preview
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom prompts, Claude Code preset, append, output styles, prompt-cache optimization
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, agents, hooks, and what each controls
- [Skills](references/claude-code-agent-sdk-skills.md) — loading skills, the `skills` option, the `Skill` tool
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — sending commands like `/compact` as SDK prompts, available commands
- [User input and approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, `onElicitation`
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate`, `TaskUpdate`, background task progress
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred MCP tool schemas, `ENABLE_TOOL_SEARCH`, `alwaysLoad`
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading local plugins via `SdkPluginConfig`
- [Observability](references/claude-code-agent-sdk-observability.md) — hook events, `includeHookEvents`, `agentProgressSummaries`, `forwardSubagentText`
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — `sessionStore`, external backends, `SessionStore` interface
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Docker, CI/CD, cloud, `spawnClaudeCodeProcess`, timeout configuration
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — sandboxing, input validation, permission hardening
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from Claude Code CLI or older SDK versions
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — upcoming TypeScript SDK API changes

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- MCP servers: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- User input and approvals: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
