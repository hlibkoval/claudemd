---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents with Python and TypeScript. Use when working with query(), ClaudeAgentOptions, ClaudeSDKClient, agent loops, sessions, subagents, hooks, permissions, MCP servers, custom tools, streaming, structured outputs, cost tracking, or deploying and hosting SDK agents.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### Installation

| Language | Package | Command |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` (requires Python 3.10+) |

Set `ANTHROPIC_API_KEY` from [platform.claude.com](https://platform.claude.com/). Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), Claude Platform on AWS (`CLAUDE_CODE_USE_ANTHROPIC_AWS=1`), and Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Core pattern

Python uses `async for` with `query()` (one-off) or `ClaudeSDKClient` (multi-turn). TypeScript uses `for await` with `query()`. Both stream `SDKMessage` objects as the agent works.

```python
from claude_agent_sdk import query, ClaudeAgentOptions, ResultMessage

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(
        allowed_tools=["Read", "Edit", "Bash"],
        permission_mode="acceptEdits",
    ),
):
    if isinstance(message, ResultMessage) and message.subtype == "success":
        print(message.result)
```

### Message types

| Type | Python class | TS `message.type` | When emitted |
| :--- | :--- | :--- | :--- |
| Session init | `SystemMessage` (subtype `"init"`) | `"system"` | First message; contains `session_id`, MCP server list |
| Claude response | `AssistantMessage` | `"assistant"` | After each model turn; contains content blocks + tool calls |
| Tool results | `UserMessage` | `"user"` | After tool execution; carries results back to Claude |
| Streaming delta | `StreamEvent` | `"stream_event"` | Only when `include_partial_messages=True` |
| Loop complete | `ResultMessage` | `"result"` | Final message; contains `result`, `total_cost_usd`, `session_id` |

In TypeScript, `AssistantMessage` wraps the API message — content is at `message.message.content`, not `message.content`.

### ResultMessage subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :---: |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

Always check `subtype` before reading `result`. All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### ClaudeAgentOptions / Options (key fields)

| Option (Python → TS) | Type | Description |
| :--- | :--- | :--- |
| `allowed_tools` → `allowedTools` | `string[]` | Auto-approve these tools; others fall through to permission mode |
| `disallowed_tools` → `disallowedTools` | `string[]` | Bare name removes from context; scoped `"Bash(rm *)"` denies matching calls |
| `permission_mode` → `permissionMode` | string | See permission modes table |
| `system_prompt` → `systemPrompt` | string | Override Claude's system prompt |
| `model` | string | Model ID or alias (`"sonnet"`, `"opus"`, `"haiku"`, `"fable"`) |
| `max_turns` → `maxTurns` | number | Cap agentic turns (tool-use rounds) |
| `max_budget_usd` → `maxBudgetUsd` | number | Stop when estimated cost exceeds this |
| `effort` | string | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `cwd` | string | Working directory for the agent |
| `setting_sources` → `settingSources` | string[] | Which filesystem sources to load: `"user"`, `"project"`, `"local"` |
| `mcp_servers` → `mcpServers` | object | MCP server configs keyed by name |
| `hooks` | object | Programmatic hook callbacks by event name |
| `agents` | object | Named `AgentDefinition` objects for subagents |
| `skills` | `"all"` or string[] | Which skills to enable (`"all"` or list of names) |
| `resume` | string | Session ID to resume |
| `fork_session` → `forkSession` | boolean | Fork the resumed session instead of continuing it |
| `continue_conversation` → `continue` | boolean | Resume the most recent session in cwd |
| `persist_session` → `persistSession` | boolean (TS only) | `false` = in-memory only, no disk write |
| `include_partial_messages` → `includePartialMessages` | boolean | Emit `StreamEvent` deltas in real time |
| `plugins` | array | Load plugins programmatically |

### Permission modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Unmatched tools call `canUseTool` callback | Interactive flows |
| `acceptEdits` | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `sed`) | Trusted dev workflows |
| `plan` | Claude explores without editing source files; edits route to `canUseTool` | Read-plan-then-approve |
| `dontAsk` | Anything not in `allowedTools` is denied; `canUseTool` never called | Locked-down headless agents |
| `auto` (TS only) | Model classifier approves/denies each call | Autonomous with safety guardrails |
| `bypassPermissions` | All tools run without prompting (except explicit `ask` rules); cannot use as root on Unix | CI/containers only |

Permission evaluation order: **hooks → deny rules → ask rules → permission mode → allow rules → canUseTool**.

`allowedTools` does not constrain `bypassPermissions` — use `disallowedTools` to block specific tools in that mode.

### Built-in tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| File operations | `Read`, `Edit`, `Write` | Read, modify, create files |
| Search | `Glob`, `Grep` | Find files by pattern; search content with regex |
| Execution | `Bash` | Run shell commands, scripts, git operations |
| Monitoring | `Monitor` | Watch background scripts, react to each output line |
| Web | `WebSearch`, `WebFetch` | Search the web, fetch and parse pages |
| Discovery | `ToolSearch` | Load MCP tool schemas on demand |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate`, `Workflow` | Spawn subagents, invoke skills, ask the user, track tasks |

### Sessions

| Operation | Python | TypeScript |
| :--- | :--- | :--- |
| Single query | `query(prompt=..., options=...)` | `query({ prompt, options })` |
| Multi-turn (auto) | `ClaudeSDKClient` as async context manager | Pass `continue: true` on subsequent calls |
| Resume specific session | `resume=session_id` in options | `resume: sessionId` in options |
| Fork a session | `resume=session_id, fork_session=True` | `resume: sessionId, forkSession: true` |
| Get session ID | `ResultMessage.session_id` (also in `SystemMessage.data` for Python) | `message.session_id` on result (also on `init` SystemMessage) |

Sessions persist to `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. For cross-host resumption, use a `SessionStore` adapter or copy the JSONL file.

### Subagents

Define via `agents` parameter in `query()`. Claude invokes them through the `Agent` tool — include `"Agent"` in `allowedTools` to auto-approve.

```python
AgentDefinition(
    description="When to use this agent",  # Required; Claude reads this to decide
    prompt="System prompt for this agent",  # Required
    tools=["Read", "Grep"],   # Optional; inherits all if omitted
    model="sonnet",           # Optional model alias or full ID
    effort="high",            # Optional reasoning effort
    max_turns=20,             # Optional turn cap
    background=False,         # True = non-blocking background task
)
```

Subagents start with a fresh conversation (no parent history). They receive their own system prompt, the Agent tool's prompt string, and project CLAUDE.md if `settingSources` includes `"project"`. Only the subagent's final message returns to the parent.

### MCP servers

Tool naming: `mcp__{server_name}__{tool_name}`. Allow with `allowedTools: ["mcp__github__*"]`.

| Transport | Config field | When to use |
| :--- | :--- | :--- |
| `stdio` | `command`, `args`, `env` | Local process (npx, python, etc.) |
| `sse` | `type: "sse"`, `url`, `headers` | Remote SSE endpoint |
| `http` | `type: "http"`, `url`, `headers` | Streamable HTTP endpoint |
| SDK in-process | `createSdkMcpServer()` / `create_sdk_mcp_server()` | Custom tools defined in code |

MCP servers can also be loaded from `.mcp.json` at the project root when `settingSources` includes `"project"`.

Tool search is enabled by default — MCP tool schemas are deferred and loaded on demand, not preloaded into every request.

### Custom tools (in-process MCP)

Python: `@tool("name", "description", {"param": type})` decorator + `create_sdk_mcp_server(name=..., tools=[...])`.
TypeScript: `tool("name", "description", { param: z.type() }, async (args) => ...)` + `createSdkMcpServer({ name, tools })`.

Pass the server via `mcp_servers={"server_name": server}` and allow with `allowed_tools=["mcp__server_name__tool_name"]`.

Handler must return `{ content: [{ type: "text", text: "..." }] }`. Set `is_error: True` (Python) / `isError: true` (TS) to signal failure without stopping the loop. Set `readOnlyHint: true` in annotations to allow parallel execution.

### SDK hooks

Register callbacks under event names in `options.hooks` (Python: `HookMatcher` objects; TypeScript: `{ matcher, hooks }` objects).

| Event | Python | TypeScript | When it fires |
| :--- | :---: | :---: | :--- |
| `PreToolUse` | Yes | Yes | Before a tool executes; can block, modify input, or allow |
| `PostToolUse` | Yes | Yes | After tool succeeds; can inject context or replace output |
| `PostToolUseFailure` | Yes | Yes | After tool fails |
| `PostToolBatch` | No | Yes | After all parallel tool calls resolve |
| `UserPromptSubmit` | Yes | Yes | When a prompt is submitted; can inject context |
| `MessageDisplay` | No | Yes | When assistant text streams; can reformat displayed text |
| `Stop` | Yes | Yes | When agent finishes |
| `SubagentStart` | Yes | Yes | When a subagent spawns |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before context compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would appear |
| `Notification` | Yes | Yes | Agent status messages (`permission_prompt`, `idle_prompt`, etc.) |
| `SessionStart` | No | Yes | Session begins |
| `SessionEnd` | No | Yes | Session ends |

Hook callback signature: `async (input_data, tool_use_id, context) -> dict`. Return `{}` to allow. For `PreToolUse`, return `hookSpecificOutput` with `permissionDecision` (`"allow"`, `"deny"`, `"ask"`, `"defer"`) and optional `permissionDecisionReason`, `updatedInput`. For `PostToolUse`, set `updatedToolOutput` to replace what Claude sees. Multiple hooks run in parallel; most restrictive `PreToolUse` decision wins.

Matcher rules: exact string or pipe-separated list (`"Write|Edit"`) when only letters/digits/underscore/pipe. Regular expression when any other character is present (e.g., `"^mcp__"`). Omitted or `"*"` matches all.

### settingSources

| Source | What loads | Location |
| :--- | :--- | :--- |
| `"project"` | Project CLAUDE.md, `.claude/rules/*.md`, project skills, hooks, `settings.json` | `<cwd>/.claude/` and parent dirs |
| `"user"` | User CLAUDE.md, `~/.claude/rules/*.md`, user skills and settings | `~/.claude/` |
| `"local"` | CLAUDE.local.md, `settings.local.json` | `<cwd>/.claude/` and parent dirs |

Omitting `settingSources` is equivalent to `["user", "project", "local"]`. Pass `[]` to disable all filesystem settings (managed policy and `~/.claude.json` always load regardless).

### Cost tracking

`ResultMessage.total_cost_usd` is a client-side estimate (not billing-authoritative). For per-step tracking, deduplicate by `message.message.id` (TS) / `message.message_id` (Python) since parallel tool calls share the same ID. `ResultMessage.model_usage` / `modelUsage` breaks down cost by model. Cache tokens appear as `cache_creation_input_tokens` and `cache_read_input_tokens`. Set `ENABLE_PROMPT_CACHING_1H` to extend cache TTL to 1 hour.

### Context window and compaction

Context accumulates across turns within a session (system prompt, tool definitions, conversation history, tool outputs). When approaching the limit, the SDK automatically compacts by summarizing older history. A `SystemMessage` with subtype `"compact_boundary"` is emitted (TypeScript: `SDKCompactBoundaryMessage`). Add summarization instructions to CLAUDE.md to control what the compactor preserves. Use a `PreCompact` hook to archive the full transcript before summarization.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — Introduction, capabilities, comparison with Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step: install, configure API key, build a bug-fixing agent
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, tool execution, context window, compaction, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — Complete TypeScript API: `query()`, `startup()`, `Options`, all message types, tool input types, hook input types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — Complete Python API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, decorators
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, hooks from filesystem, feature selection guide
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — Permission evaluation order, allow/deny rules, all permission modes with detail
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — Hook configuration, matchers, callback inputs/outputs, async hooks, examples (block tools, modify input, webhooks, Slack notifications)
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — Transport types (stdio, SSE, HTTP), authentication, tool search, error handling, examples
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP servers, tool annotations, error handling, returning images/resources/structured data
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — AgentDefinition, context isolation, parallelization, tool restrictions, resuming subagents
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — `ClaudeSDKClient`, `continue`, `resume`, `fork`, cross-host resumption, session utilities
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — SessionStore adapters for cross-host session resumption
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and revert file changes the agent made
- [Stream responses](references/claude-code-agent-sdk-streaming-output.md) — Partial messages, `StreamEvent`, live text and tool call streaming
- [Streaming vs. single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to collect all messages vs. stream; background job patterns
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — Constrain agent output to a JSON schema
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive approval flows
- [Modify system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Override, append, or prepend to the system prompt
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — Per-step usage, per-model breakdown, cache tokens, accumulating across calls
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool schema loading, configuration options
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — Using skills programmatically via `settingSources` and the `skills` option
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — Using commands (e.g., `/compact`) as prompt strings in the SDK
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate` / `TaskUpdate` tools for structured task lists
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, telemetry, and monitoring agent runs
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — Loading plugins programmatically via the `plugins` option
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Docker, cloud deployment, CI/CD integration
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Multi-tenant isolation, sandbox configuration, security hardening
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from older SDK versions
- [TypeScript V2 preview (removed)](references/claude-code-agent-sdk-typescript-v2-preview.md) — The `createSession()` V2 API was removed in v0.3.142; use `query()` with session options instead

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modify system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Agent SDK reference - Python: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Stream responses: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs. single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Agent SDK reference - TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
