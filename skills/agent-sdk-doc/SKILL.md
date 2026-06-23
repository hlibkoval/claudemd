---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the Python and TypeScript library for building production AI agents that autonomously read files, run commands, search the web, edit code, and more.

## Quick Reference

### Installation

| Language | Package | Command |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` (Python 3.10+) |

The TypeScript SDK bundles a native Claude Code binary as an optional dependency; no separate CLI install needed.

### Entry Point: `query()`

Both SDKs expose a `query()` function that returns an async generator of messages:

- **Python**: `async for message in query(prompt="...", options=ClaudeAgentOptions(...))`
- **TypeScript**: `for await (const message of query({ prompt: "...", options: {...} }))`

The Python SDK also provides `ClaudeSDKClient` for multi-turn conversations within one process (automatic session continuity across multiple `query()` calls).

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read files in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run shell commands, scripts, git operations |
| `Monitor` | Watch a background script and react to each output line |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options |
| `Agent` | Spawn subagents for isolated subtasks |
| `Skill` | Invoke named skills |
| `ToolSearch` | Dynamically find and load tools on demand |
| `TaskCreate` / `TaskUpdate` | Track background tasks |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | No auto-approvals; unmatched tools call `canUseTool` | Interactive apps with custom approval UI |
| `acceptEdits` | Auto-approves file edits and common filesystem commands (`mkdir`, `rm`, `mv`, etc.) | Trusted development workflows |
| `plan` | Read-only exploration; file edits always prompt | Code review, safe planning |
| `dontAsk` | Anything not pre-approved is denied (no prompt) | Locked-down headless agents |
| `bypassPermissions` | All tools run without prompting (explicit `ask` rules still fire) | Sandboxed CI, isolated containers |
| `auto` (TypeScript only) | Model classifier approves/denies each tool call | Autonomous agents with safety guardrails |

### Permission Evaluation Order

1. **Hooks** — can allow, deny, or modify before anything else
2. **Deny rules** (`disallowed_tools`) — blocks tool outright (bare name removes from context; scoped `Bash(rm *)` keeps tool but blocks pattern)
3. **Ask rules** (from `settings.json`) — routes to `canUseTool` even in `bypassPermissions`
4. **Permission mode** — `bypassPermissions` approves here; `acceptEdits` approves file ops here
5. **Allow rules** (`allowed_tools`) — pre-approved tools proceed
6. **`canUseTool` callback** — final decision for unresolved calls (skipped in `dontAsk`)

### Key Options

| Option (Python / TypeScript) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Auto-approve listed tools (does NOT restrict Claude to only these) |
| `disallowed_tools` / `disallowedTools` | Block tools entirely or scope to patterns |
| `permission_mode` / `permissionMode` | Set the permission mode |
| `can_use_tool` / `canUseTool` | Callback for interactive approval decisions |
| `max_turns` / `maxTurns` | Max tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | Stop when estimated spend reaches this USD value |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Pin a specific Claude model |
| `system_prompt` / `systemPrompt` | Custom system prompt or `{type:"preset", preset:"claude_code"}` |
| `mcp_servers` / `mcpServers` | Connect external MCP servers (databases, browsers, APIs) |
| `agents` | Define subagents programmatically |
| `hooks` | Callback hooks for agent lifecycle events |
| `resume` | Resume a past session by ID |
| `continue_conversation` / `continue` | Resume the most recent session in current directory |
| `fork_session` / `forkSession` | Fork history into a new session instead of continuing |
| `setting_sources` / `settingSources` | Which filesystem settings to load: `"user"`, `"project"`, `"local"` |
| `plugins` | Load local plugins (`{type:"local", path:"./my-plugin"}`) |
| `output_format` / `outputFormat` | Structured JSON output schema |
| `enable_file_checkpointing` / `enableFileCheckpointing` | Track file changes for rewind |
| `session_store` / `sessionStore` | Mirror transcripts to external storage for cross-host resume |

### Message Types

| Type | Python class | TypeScript `type` | When emitted |
| :--- | :--- | :--- | :--- |
| System/init | `SystemMessage` (subtype `"init"`) | `"system"` / `subtype:"init"` | First message; contains `session_id`, tools, model |
| Assistant response | `AssistantMessage` | `"assistant"` | After each Claude turn |
| Tool results | `UserMessage` | `"user"` | After tool execution |
| Streaming chunk | `StreamEvent` | `"stream_event"` | When `include_partial_messages=True` |
| Final result | `ResultMessage` | `"result"` | Loop ends; contains cost, usage, `session_id` |

In TypeScript, `AssistantMessage` content is at `message.message.content` (not `message.content`). In Python, check types with `isinstance(message, ResultMessage)`.

### Result Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled request | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Sessions

| Goal | How |
| :--- | :--- |
| Multi-turn in one process (Python) | Use `ClaudeSDKClient`; each `.query()` auto-continues |
| Multi-turn in one process (TypeScript) | Pass `continue: true` on subsequent `query()` calls |
| Resume a specific session | Capture `session_id` from `ResultMessage`; pass to `resume` |
| Fork history | Pass `resume=<id>` + `fork_session=True` / `forkSession: true` |
| Cross-host resume | Mirror with `session_store` / `sessionStore` adapter, or move the `.jsonl` file |
| List/inspect sessions | `list_sessions()` / `listSessions()`, `get_session_info()` / `getSessionInfo()` |
| Rename/tag sessions | `rename_session()` / `renameSession()`, `tag_session()` / `tagSession()` |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.

### Hooks (SDK Callback Form)

SDK hooks are registered as callback functions in `options.hooks`, not shell commands. Python uses `HookMatcher`; TypeScript uses `HookCallbackMatcher`.

```python
# Python example
hooks={
    "PreToolUse": [HookMatcher(matcher="Write|Edit", hooks=[my_callback])]
}
```

Available hook events in the SDK: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PermissionRequest`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`, `MessageDisplay`, `Notification`, `Setup`.

Hook callbacks receive `(input_data, tool_use_id, context)` and return a dict. Return `{}` to allow; return `hookSpecificOutput.permissionDecision: "deny"` to block.

### Subagents

Define via `agents` option as `AgentDefinition`. Include `"Agent"` in `allowedTools` to auto-approve invocations. Claude delegates based on the `description` field.

Key `AgentDefinition` fields: `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model`, `mcpServers`, `skills`, `maxTurns`, `background`, `effort`, `permissionMode`.

Subagents run in a fresh context — no parent conversation history, only their own system prompt, CLAUDE.md, and tool definitions. Only the final response returns to the parent.

### Custom Tools

Use `@tool` decorator (Python) or `tool()` function (TypeScript) + `create_sdk_mcp_server()` / `createSdkMcpServer()`:

```python
@tool("search", "Search the web", {"query": str})
async def search(args):
    return {"content": [{"type": "text", "text": f"Results for: {args['query']}"}]}

server = create_sdk_mcp_server(name="mytools", tools=[search])
options = ClaudeAgentOptions(mcp_servers={"mytools": server}, allowed_tools=["mcp__mytools__search"])
```

Set `readOnlyHint=True` in `ToolAnnotations` to enable parallel execution for tools with no side effects.

### MCP Servers

```python
# Stdio MCP server
mcp_servers={"playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}}

# SSE/HTTP server
mcp_servers={"myserver": {"type": "sse", "url": "https://api.example.com/mcp"}}
```

MCP tools are named `mcp__<server>__<tool>`. Use `strictMcpConfig: true` to ignore project `.mcp.json` and use only the programmatic config.

### Context Window Management

- Content accumulates across turns (prompts, tool inputs, tool outputs)
- System prompt, tool definitions, and CLAUDE.md are prompt-cached automatically
- Automatic compaction triggers when context nears the limit (emits `compact_boundary` message)
- To preserve info through compaction: put it in CLAUDE.md (reinjected every request)
- Use subagents for subtasks to keep main context lean
- Set lower `effort` for routine tasks; use `tool_search` to defer MCP tool schema loading

### Effort Levels

| Level | Behavior | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal reasoning | File lookups, listing directories |
| `"medium"` | Balanced reasoning | Routine edits, standard tasks |
| `"high"` | Thorough analysis | Refactors, debugging |
| `"xhigh"` | Extended reasoning depth | Recommended on Fable 5 and Opus 4.7+ |
| `"max"` | Maximum reasoning depth | Multi-step problems requiring deep analysis |

### TypeScript-Only Features

- `startup()` — pre-warm the CLI subprocess before a prompt is ready (reduces latency)
- `permissionMode: "auto"` — model classifier for tool approval
- `applyFlagSettings()` on `Query` object — change settings mid-session without restart
- `persistSession: false` — in-memory only session, not saved to disk
- `resolveSettings()` — inspect merged settings without spawning Claude
- `Query.rewindFiles()` — restore files to state at a given message (requires `enableFileCheckpointing`)

### Python-Only Classes

- `ClaudeSDKClient` — stateful client for multi-turn conversations with automatic session continuity, interrupt support, and `receive_response()` iteration
- `Transport` — abstract base for custom transport implementations

### Structured Outputs

Pass a JSON Schema via `output_format` / `outputFormat`:

```python
output_format={"type": "json_schema", "schema": {"type": "object", "properties": {...}}}
```

The SDK validates and retries if the model returns invalid output. On `error_max_structured_output_retries`, every attempt failed.

### Authentication

| Provider | Environment variable |
| :--- | :--- |
| Anthropic (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK capabilities, comparison to Client SDK and CLI, getting started
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent end-to-end; permission modes and tool combos
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Turns, messages, context window, compaction, hooks, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — Full API: `query()`, `startup()`, `tool()`, `Options`, all message types, hook types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — Full API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types and classes
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; automatic session management; cross-host resume
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, evaluation order, dynamic mode changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Callback hooks; blocking tools; modifying inputs; audit logging patterns
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Define subagents, context isolation, parallel execution, what subagents inherit
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `@tool` decorator, in-process MCP server, annotations, error handling, images
- [MCP integration](references/claude-code-agent-sdk-mcp.md) — Connect MCP servers, tool naming, tool search, in-process servers
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — CLAUDE.md, skills, commands, plugins via `settingSources`
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom prompts, preset, append, output styles, prompt caching
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — Enable partial messages, handle stream events in real time
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming input mode vs one-shot queries; when to use each
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema output format, validation, retry behavior
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage` fields, per-model breakdown
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, handling clarifying questions
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Track and rewind file changes; `enableFileCheckpointing`, `rewindFiles()`
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for external storage backends; cross-host resume
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool schema loading; `ToolSearch` built-in tool
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — Loading skills via `settingSources` or `skills` option
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — Using commands like `/compact` as prompt strings
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — Loading local plugins programmatically
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Deploy to Docker, cloud, CI/CD; sandboxing; secure deployment
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Security hardening, sandboxing, network policies
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, debugging, monitoring agent runs
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — Task tracking with `TaskCreate` / `TaskUpdate` tools
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from older SDK versions
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Historical v2 session API (removed in v0.3.142; use `query()` instead)

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
- MCP integration: https://code.claude.com/docs/en/agent-sdk/mcp.md
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
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
