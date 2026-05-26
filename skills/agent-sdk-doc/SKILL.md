---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — Python and TypeScript APIs for embedding the Claude Code agent loop in your own applications, including query(), ClaudeSDKClient, ClaudeAgentOptions/Options, permission modes, hooks, sessions, subagents, custom tools, MCP integration, structured outputs, streaming, hosting, and security.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### What the Agent SDK Is

The Claude Agent SDK lets you embed Claude Code's autonomous agent loop in Python or TypeScript applications. Claude autonomously reads files, runs commands, edits code, and more — you consume a stream of messages. No tool execution loop to implement yourself.

| Package | Install |
| :--- | :--- |
| Python | `pip install claude-agent-sdk` |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` |

Authentication: set `ANTHROPIC_API_KEY`. Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), and Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Core Entry Points

**Python: `query()` vs `ClaudeSDKClient`**

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New each call | Reuses same session |
| Conversation | Single exchange | Multiple exchanges in same context |
| Interrupts | No | Yes |
| Use case | One-off tasks | Continuous conversations |

**TypeScript: `query()`** is the only entry point. Use `continue: true` or `resume: sessionId` to continue sessions. Use `startup()` to pre-warm the subprocess before a prompt is available.

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script and react to output lines |
| `Glob` | Find files by pattern |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple choice |
| `Agent` | Spawn a subagent |
| `Skill` | Load a skill into context |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Calls `canUseTool` callback for unlisted tools | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and common filesystem ops | Trusted dev workflows |
| `dontAsk` | Denies anything not in `allowedTools` | Locked-down headless agents |
| `auto` (TypeScript only) | Model classifier approves or denies each call | Autonomous with safety guardrails |
| `bypassPermissions` | Runs every tool without prompts | Sandboxed CI, fully trusted environments |
| `plan` | Read-only tools only | Planning-only mode |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

- `allowedTools` pre-approves listed tools; unlisted tools fall through to the permission mode.
- `disallowed_tools=["Bash"]` removes the tool from Claude's context entirely.
- `disallowed_tools=["Bash(rm *)"]` keeps `Bash` available but denies matching calls in every mode, including `bypassPermissions`.

### Key `ClaudeAgentOptions` / `Options` Fields

| Field (Python / TypeScript) | Default | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `[]` | Auto-approve these tools |
| `disallowed_tools` / `disallowedTools` | `[]` | Deny these tools (bare name removes from context) |
| `permission_mode` / `permissionMode` | `None` / `'default'` | Permission mode |
| `system_prompt` / `systemPrompt` | `None` | Custom system prompt or `{"type": "preset", "preset": "claude_code"}` |
| `mcp_servers` / `mcpServers` | `{}` | MCP server configs |
| `resume` | `None` | Session ID to resume |
| `continue_conversation` / `continue` | `False` | Resume most recent session |
| `fork_session` / `forkSession` | `False` | Fork session instead of continuing |
| `max_turns` / `maxTurns` | `None` | Max agentic turns |
| `max_budget_usd` / `maxBudgetUsd` | `None` | Stop at this USD estimate |
| `model` | `None` | Claude model to use |
| `cwd` | `None` | Working directory |
| `hooks` | `None` / `{}` | SDK hook callbacks |
| `agents` | `None` / `{}` | Programmatic subagent definitions |
| `setting_sources` / `settingSources` | All sources | Which filesystem settings to load; pass `[]` to disable |
| `thinking` | `None` | `ThinkingConfig`: `{"type": "adaptive"}`, `{"type": "enabled", "budget_tokens": N}`, or `{"type": "disabled"}` |
| `effort` | `None` / `'high'` | Effort level: `low`, `medium`, `high`, `xhigh`, `max` |
| `plugins` | `[]` | Load local plugins: `[{"type": "local", "path": "..."}]` |
| `skills` | `None` | Skills available to session: list of names or `'all'` / `"all"` |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `False` | Track file changes for rewinding |
| `output_format` / `outputFormat` | `None` | Structured output: `{"type": "json_schema", "schema": {...}}` |
| `sandbox` | `None` | Programmatic sandbox settings |
| `session_store` / `sessionStore` | `None` | External session storage backend |

### Message Types

| Type / subtype | What it is |
| :--- | :--- |
| `system` / `init` | Session initialization with metadata (tools, model, session_id, etc.) |
| `assistant` | Claude's text responses and tool call requests |
| `user` | Tool results fed back to Claude |
| `result` / `success` | Final result with text, cost, usage, and session_id |
| `result` / `error_max_turns` etc. | Error result subtypes |
| `system` / `compact_boundary` | Context compaction happened |
| `stream_event` | Partial streaming event (only when `includePartialMessages: true`) |

The `result` message's `total_cost_usd` is a client-side estimate. Key fields: `session_id`, `num_turns`, `usage`, `modelUsage`, `stop_reason`, `terminal_reason`.

### Sessions: Continue, Resume, Fork

| Goal | How |
| :--- | :--- |
| Multi-turn in one process | Python: `ClaudeSDKClient`; TypeScript: `continue: true` |
| Resume most-recent session after restart | `continue_conversation=True` / `continue: true` |
| Resume a specific session by ID | `resume="<session_id>"` |
| Branch off without losing original | `fork_session=True` / `forkSession: true` with `resume` |
| Stateless (no disk writes) | TypeScript only: `persistSession: false` |

Capture session ID from the `system`/`init` message: Python `message.data["session_id"]`, TypeScript `message.session_id`.

Session management functions: `list_sessions()` / `listSessions()`, `get_session_messages()` / `getSessionMessages()`, `get_session_info()` / `getSessionInfo()`, `rename_session()` / `renameSession()`, `tag_session()` / `tagSession()`.

### Hooks (SDK Callbacks)

Hooks intercept agent events. Register them in `ClaudeAgentOptions.hooks` / `options.hooks`:

```python
# Python
options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [
            HookMatcher(matcher="Write|Edit", hooks=[my_callback])
        ]
    }
)
```

```typescript
// TypeScript
options = {
  hooks: {
    PreToolUse: [{ matcher: "Write|Edit", hooks: [myCallback] }]
  }
}
```

Hook callback signature:
- Python: `async def callback(input_data, tool_use_id, context) -> dict`
- TypeScript: `(input: HookInput, toolUseID: string | undefined, options: { signal: AbortSignal }) => Promise<HookJSONOutput>`

Key hook output fields for `PreToolUse`: `hookSpecificOutput.permissionDecision` (`"allow"` / `"deny"` / `"ask"` / `"defer"`), `hookSpecificOutput.permissionDecisionReason`, `hookSpecificOutput.updatedInput`.

Available hook events in the SDK: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Notification`, `UserPromptSubmit`, `SessionStart`, `SessionEnd`, `Stop`, `SubagentStart`, `SubagentStop`, `PreCompact`, `PermissionRequest`, `Setup`, `TeammateIdle`, `TaskCompleted`, `ConfigChange`, `WorktreeCreate`, `WorktreeRemove`.

### Custom Tools (In-Process MCP)

Define tools with `@tool` (Python) or `tool()` (TypeScript), bundle into an in-process MCP server, and pass to `mcp_servers`:

```python
# Python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("greet", "Greet a user", {"name": str})
async def greet(args):
    return {"content": [{"type": "text", "text": f"Hello, {args['name']}!"}]}

server = create_sdk_mcp_server(name="my-server", tools=[greet])
options = ClaudeAgentOptions(mcp_servers={"srv": server},
                              allowed_tools=["mcp__srv__greet"])
```

```typescript
// TypeScript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const greetTool = tool("greet", "Greet a user", { name: z.string() },
  async ({ name }) => ({ content: [{ type: "text", text: `Hello, ${name}!` }] })
);
const server = createSdkMcpServer({ name: "my-server", tools: [greetTool] });
```

Return `isError: true` in the content array to signal an error without stopping the loop. Return `image` or `resource` content blocks for non-text output. Use `structuredContent` for machine-readable JSON results.

### Subagents

Define subagents in `AgentDefinition` / `agents` option. Include `"Agent"` in `allowedTools` to auto-approve invocations.

Key `AgentDefinition` fields: `description` (required — tells Claude when to use the agent), `prompt` (required — system prompt), `tools`, `disallowedTools`, `model` (alias: `"sonnet"`, `"opus"`, `"haiku"`, `"inherit"`), `skills`, `maxTurns`, `background` (run as non-blocking task), `effort`, `permissionMode`.

Messages from within subagent context include a `parent_tool_use_id` field. `AgentDefinition` uses camelCase field names in both Python and TypeScript (unlike `ClaudeAgentOptions` which uses Python snake_case).

### System Prompt Options

| Value | Effect |
| :--- | :--- |
| A string | Custom system prompt (replaces default) |
| `{"type": "preset", "preset": "claude_code"}` | Use Claude Code's full system prompt |
| `{"type": "preset", "preset": "claude_code", "append": "..."}` | Extend Claude Code's system prompt |
| `{"type": "preset", "preset": "claude_code", "excludeDynamicSections": true}` | Moves per-session context to first user message for better prompt cache reuse |
| Omitted | Minimal system prompt |

### Timeout Environment Variables

Pass via `env` option (`ClaudeAgentOptions.env` in Python, `options.env` in TypeScript):

| Variable | Default | Description |
| :--- | :--- | :--- |
| `API_TIMEOUT_MS` | `600000` | Per-request timeout |
| `CLAUDE_CODE_MAX_RETRIES` | `10` | Max API retries |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | `600000` | Background subagent stall watchdog |
| `CLAUDE_ENABLE_STREAM_WATCHDOG=1` + `CLAUDE_STREAM_IDLE_TIMEOUT_MS` | Off / `300000` | Abort on stalled response body |

Note: TypeScript `env` **replaces** the subprocess environment; pass `{ ...process.env, YOUR_VAR: "value" }` to preserve `PATH` and other inherited vars. Python `env` merges on top of the inherited environment.

### TypeScript-Only: `Query` Object Methods

The `query()` return value exposes runtime control methods (streaming input mode only):
`interrupt()`, `rewindFiles(userMessageId)`, `setPermissionMode(mode)`, `setModel(model)`, `applyFlagSettings(settings)`, `stopTask(taskId)`, `reconnectMcpServer(name)`, `toggleMcpServer(name, enabled)`, `setMcpServers(servers)`, `streamInput(stream)`.

Also: `initializationResult()`, `supportedCommands()`, `supportedModels()`, `supportedAgents()`, `mcpServerStatus()`, `accountInfo()`.

TypeScript also provides `startup()` to pre-warm the subprocess for lower latency on the first query.

### File Checkpointing

Enable with `enable_file_checkpointing=True` / `enableFileCheckpointing: true`. Tracks file snapshots at each user message. Rewind with `client.rewind_files(user_message_id)` (Python) or `query.rewindFiles(userMessageId)` (TypeScript).

### External Session Storage

Implement the `SessionStore` interface and pass to `session_store` / `sessionStore`. Methods: `save(sessionId, entries)` / `append`, `load(sessionId)`, `listKeys()`, `listSubkeys(sessionId)`. Enables resuming sessions across hosts.

### Structured Outputs

Pass `output_format` / `outputFormat` as `{"type": "json_schema", "schema": {...}}`. The result appears in `result.structured_output`. The agent retries on validation failures (up to a limit; result subtype `error_max_structured_output_retries`).

### Hosting and Security

- Run inside a container for isolation; each SDK instance needs its own container for multi-tenant scenarios.
- `SandboxSettings` / `sandbox` option: configure command sandbox behavior programmatically.
- `secure-deployment` reference covers network controls, credential management, and isolation.
- TypeScript single-file executables: use `extractFromBunfs()` helper (v0.3.144+) to extract the bundled CLI binary.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — capabilities overview, built-in tools, hooks, subagents, MCP, permissions, sessions; comparison with Client SDK, CLI, and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to building a bug-fixing agent in Python or TypeScript
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, and message types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — complete API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types and classes
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — complete API: `query()`, `Options`, `Query` object, all message and hook types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; automatic session management; cross-host sessions
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, permission modes, canUseTool callback
- [Hooks](references/claude-code-agent-sdk-hooks.md) — intercepting events with callback functions, matchers, blocking/modifying tool calls
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — in-process MCP servers, tool definitions, error handling, annotations, images/resources
- [Subagents](references/claude-code-agent-sdk-subagents.md) — defining subagents programmatically, context isolation, parallelization, background tasks
- [MCP integration](references/claude-code-agent-sdk-mcp.md) — connecting external MCP servers (stdio, SSE, HTTP), per-agent MCP, tool naming
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom prompts, preset, append, output styles, prompt cache optimization
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — message streaming patterns, filtering, progress display
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use streaming input mode vs one-shot queries
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON schema output format, validation, retry behavior
- [User input](references/claude-code-agent-sdk-user-input.md) — AskUserQuestion tool, canUseTool callback, interactive approval flows
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — skills, slash commands, CLAUDE.md memory, plugins; settingSources control
- [Skills](references/claude-code-agent-sdk-skills.md) — loading and using skills in SDK sessions
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — custom commands in SDK sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading local plugins programmatically
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — loading tools on demand for large tool sets
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, tracing, monitoring agent behavior
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — tracking token usage and cost estimates
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — TodoRead/TodoWrite tools for task management
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshotting and rewinding file changes
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — external session storage interface for cross-host resume
- [Hosting](references/claude-code-agent-sdk-hosting.md) — production deployment, containers, system requirements
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — upgrading between SDK versions
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — preview features in the TypeScript SDK
- [Agent loop internals](references/claude-code-agent-sdk-agent-loop.md) — deep dive into turn mechanics, context window management

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
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
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
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
