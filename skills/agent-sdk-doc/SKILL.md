---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the Python and TypeScript library for building production AI agents with Claude Code's autonomous agent loop.

## Quick Reference

### Installation

| Language   | Package                          | Install command                            |
| :--------- | :------------------------------- | :----------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`               | `pip install claude-agent-sdk`             |

The TypeScript SDK bundles a native Claude Code binary; no separate CLI install is needed.

**Migration note:** Formerly `@anthropic-ai/claude-code` (TS) / `claude-code-sdk` (Python). Update imports accordingly.

### Authentication

| Provider              | Environment variable(s)                                           |
| :-------------------- | :---------------------------------------------------------------- |
| Anthropic API (default) | `ANTHROPIC_API_KEY`                                             |
| Amazon Bedrock        | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials                    |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI      | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials                     |
| Microsoft Azure       | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials                  |

### Core entry points

| Python                              | TypeScript                        | Purpose                                         |
| :---------------------------------- | :-------------------------------- | :---------------------------------------------- |
| `query(prompt, options)`            | `query({ prompt, options })`      | Run agent, stream messages as async iterator    |
| `ClaudeSDKClient`                   | `continue: true` option           | Multi-turn conversation management              |
| `tool()` decorator                  | `tool()` function                 | Define custom MCP tools                         |
| `create_sdk_mcp_server()`           | `createSdkMcpServer()`            | Bundle custom tools into an in-process MCP server |
| `list_sessions()` / `get_session_messages()` | `listSessions()` / `getSessionMessages()` | Enumerate and read past sessions |
| `startup()`                         | `startup()`                       | Pre-warm CLI subprocess to reduce first-call latency |

### Python: `query()` vs `ClaudeSDKClient`

| Feature             | `query()`                    | `ClaudeSDKClient`              |
| :------------------ | :--------------------------- | :----------------------------- |
| Session             | New session by default       | Reuses same session            |
| Multi-turn          | Via `resume`/`continue_conversation` | Automatic              |
| Interrupts          | Not supported                | Supported                      |
| Best for            | One-off tasks                | Continuous conversation        |

### `ClaudeAgentOptions` / `Options` — key fields

| Field (Python / TypeScript)                 | Type                   | Default      | Description                                                         |
| :------------------------------------------ | :--------------------- | :----------- | :------------------------------------------------------------------ |
| `allowed_tools` / `allowedTools`            | `list[str]`            | `[]`         | Auto-approve listed tools; others fall through to permission mode   |
| `disallowed_tools` / `disallowedTools`      | `list[str]`            | `[]`         | Bare name removes tool; scoped `"Bash(rm *)"` denies in all modes   |
| `permission_mode` / `permissionMode`        | `PermissionMode`       | `"default"`  | Global tool approval behavior                                       |
| `system_prompt` / `systemPrompt`            | `str \| preset`        | `None`       | Custom prompt or `{type:"preset",preset:"claude_code"}`             |
| `max_turns` / `maxTurns`                    | `int`                  | No limit     | Maximum tool-use round trips                                        |
| `max_budget_usd` / `maxBudgetUsd`           | `float`                | No limit     | Stop when estimated cost reaches this USD value                     |
| `effort`                                    | `EffortLevel`          | `"high"` (TS) | Reasoning depth: `low`, `medium`, `high`, `xhigh`, `max`          |
| `model`                                     | `str`                  | CLI default  | Model ID or alias (`sonnet`, `opus`, `haiku`, `inherit`)            |
| `resume`                                    | `str`                  | `None`       | Session ID to resume                                                |
| `continue_conversation` / `continue`        | `bool`                 | `False`      | Resume the most recent session in `cwd`                             |
| `fork_session` / `forkSession`              | `bool`                 | `False`      | Fork (branch) from `resume` into a new session                      |
| `mcp_servers` / `mcpServers`                | `dict`                 | `{}`         | MCP server configurations                                           |
| `hooks`                                     | `dict`                 | `{}`         | Hook callbacks by event name                                        |
| `agents`                                    | `dict`                 | `None`       | Programmatic subagent definitions                                   |
| `setting_sources` / `settingSources`        | `list[str]`            | All          | Which filesystem settings to load: `user`, `project`, `local`       |
| `skills`                                    | `list[str] \| "all"`   | `None`       | Skills to enable; enables Skill tool automatically                  |
| `plugins`                                   | `list`                 | `[]`         | Load local plugins via `{type:"local", path:"..."}`                 |
| `output_format` / `outputFormat`            | `dict`                 | `None`       | JSON Schema for structured output                                   |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `bool`   | `False`      | Track file changes for rewind                                       |
| `thinking`                                  | `ThinkingConfig`       | `adaptive`   | `{type:"adaptive"}`, `{type:"enabled",budget_tokens:N}`, or `{type:"disabled"}` |
| `session_store` / `sessionStore`            | `SessionStore`         | `None`       | Mirror transcripts to external storage for cross-host resume         |
| `sandbox`                                   | `SandboxSettings`      | `None`       | Programmatic sandbox configuration                                  |
| `cwd`                                       | `str`                  | `process.cwd()` | Working directory                                                |
| `strict_mcp_config` / `strictMcpConfig`     | `bool`                 | `False`      | Use only `mcpServers` provided; ignore `.mcp.json` and user settings |

### Permission modes

| Mode                 | Description                                                                           | Notes                                       |
| :------------------- | :------------------------------------------------------------------------------------ | :------------------------------------------ |
| `default`            | No auto-approvals; unresolved tools call `canUseTool`                                 |                                             |
| `acceptEdits`        | Auto-approves file edits (`Edit`, `Write`) and filesystem shell ops (`mkdir`, `mv`, `rm`…) |                                        |
| `dontAsk`            | Deny anything not pre-approved; never calls `canUseTool`                              | Use with `allowedTools` for locked-down agents |
| `plan`               | Read-only; Claude explores and plans but does not edit source files                   |                                             |
| `auto`               | Model classifier approves or denies each tool call                                    | TypeScript only                             |
| `bypassPermissions`  | All tools run without prompts                                                         | Require `allowDangerouslySkipPermissions: true` (TS); sandboxed CI only |

**Permission evaluation order:** hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

### Message types

| Type (Python class / TS `type` string) | When emitted                                      | Key fields                                          |
| :------------------------------------- | :------------------------------------------------ | :-------------------------------------------------- |
| `SystemMessage` / `"system"` init      | First, on session start                           | `session_id`, `tools`, `model`, `permissionMode`    |
| `AssistantMessage` / `"assistant"`     | After each Claude response                        | `content` (text + tool_use blocks), `usage`         |
| `UserMessage` / `"user"`               | After each tool execution                         | `message` (tool results)                            |
| `ResultMessage` / `"result"`           | Final message; end of loop                        | `subtype`, `result`, `total_cost_usd`, `session_id` |
| `StreamEvent` / `"stream_event"`       | Only with `includePartialMessages: true`          | Raw API streaming events                            |

**ResultMessage subtypes:**

| Subtype                              | Has `result` field? | Meaning                                      |
| :----------------------------------- | :-----------------: | :------------------------------------------- |
| `success`                            | Yes                 | Task completed normally                      |
| `error_max_turns`                    | No                  | Hit `maxTurns` limit                         |
| `error_max_budget_usd`               | No                  | Hit `maxBudgetUsd` limit                     |
| `error_during_execution`             | No                  | API failure, cancellation, or interruption   |
| `error_max_structured_output_retries`| No                  | Structured output validation failed          |

### Built-in tools

| Category        | Tools                                          | What they do                                       |
| :-------------- | :--------------------------------------------- | :------------------------------------------------- |
| File operations | `Read`, `Edit`, `Write`                        | Read, modify, and create files                     |
| Search          | `Glob`, `Grep`                                 | Find files by pattern; search content with regex   |
| Execution       | `Bash`                                         | Run shell commands, scripts, git operations        |
| Web             | `WebSearch`, `WebFetch`                        | Search the web; fetch and parse pages              |
| User input      | `AskUserQuestion`                              | Ask the user a clarifying question with choices    |
| Background      | `Monitor`                                      | Watch a background script and react to output lines |
| Orchestration   | `Agent`, `Skill`, `TaskCreate`, `TaskUpdate`   | Spawn subagents, invoke skills, track tasks        |
| Discovery       | `ToolSearch`                                   | Load MCP tool schemas on demand                    |

**Tool permission rules:**
- `allowed_tools=["Read"]` — auto-approves `Read`; other tools still available, fall through to mode
- `disallowed_tools=["Bash"]` — removes `Bash` entirely from Claude's context
- `disallowed_tools=["Bash(rm *)"]` — `Bash` stays; `rm *` patterns denied in every mode including `bypassPermissions`

### Session management

| Approach                      | Python                                     | TypeScript                          | Use case                                    |
| :---------------------------- | :----------------------------------------- | :---------------------------------- | :------------------------------------------ |
| Single session, auto-managed  | `ClaudeSDKClient`                          | `continue: true`                    | Multi-turn in one process                   |
| Resume most recent            | `continue_conversation=True`               | `continue: true`                    | Restart after process exit                  |
| Resume specific session       | `resume=session_id`                        | `resume: sessionId`                 | Return to a specific past run               |
| Fork                          | `resume=id, fork_session=True`             | `resume: id, forkSession: true`     | Branch without touching original            |
| Disable persistence (TS only) | N/A                                        | `persistSession: false`             | Stateless lambda/serverless                 |

Session files stored at: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`

Session utility functions (both SDKs): `list_sessions` / `listSessions`, `get_session_messages` / `getSessionMessages`, `get_session_info` / `getSessionInfo`, `rename_session` / `renameSession`, `tag_session` / `tagSession`.

### Subagents

Define programmatically via the `agents` option. Include `"Agent"` in `allowedTools` since subagents are invoked through the Agent tool.

**`AgentDefinition` key fields:**

| Field            | Required | Description                                                            |
| :--------------- | :------- | :--------------------------------------------------------------------- |
| `description`    | Yes      | When Claude should use this agent (Claude reads this to decide)        |
| `prompt`         | Yes      | System prompt / instructions for the subagent                          |
| `tools`          | No       | Allowed tools (inherits all from parent if omitted)                    |
| `model`          | No       | Model override: full ID or alias (`sonnet`, `opus`, `haiku`, `inherit`) |
| `background`     | No       | Run as non-blocking background task                                    |
| `maxTurns`       | No       | Per-subagent turn limit                                                |
| `effort`         | No       | Per-subagent reasoning depth                                           |
| `permissionMode` | No       | Per-subagent permission mode                                           |
| `skills`         | No       | Skills to preload into this subagent's context                         |

**Note (Python):** `AgentDefinition` uses camelCase field names (`disallowedTools`, `permissionMode`, `maxTurns`) unlike `ClaudeAgentOptions` which uses snake_case.

### Hooks (SDK callbacks)

Register hooks as async callback functions in `options.hooks`:

```python
options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [HookMatcher(matcher="Edit|Write", hooks=[my_callback])]
    }
)
```

Callback signature (Python): `async def cb(input_data, tool_use_id, context) -> dict`
Callback signature (TypeScript): `async (input: HookInput, toolUseId, options) => HookJSONOutput`

**Available hook events (SDK callbacks):**

| Event              | Fires when                                  | Can block? |
| :----------------- | :------------------------------------------ | :--------- |
| `PreToolUse`       | Before a tool executes                      | Yes        |
| `PostToolUse`      | After a tool succeeds                       | No         |
| `PostToolUseFailure` | After a tool fails                        | No         |
| `PostToolBatch`    | After all tools in a parallel batch resolve | Yes        |
| `UserPromptSubmit` | When a prompt is sent                       | Yes        |
| `SessionStart`     | Session starts or resumes                   | No         |
| `SessionEnd`       | Session terminates                          | No         |
| `Stop`             | Agent finishes                              | Yes        |
| `SubagentStart`    | Subagent spawns                             | No         |
| `SubagentStop`     | Subagent finishes                           | Yes        |
| `PreCompact`       | Before context compaction                   | Yes        |
| `Notification`     | Claude sends a notification                 | No         |
| `PermissionRequest`| Permission dialog about to appear           | Yes        |
| `Setup`            | Init-only / maintenance mode start          | No         |
| `TeammateIdle`     | Agent team teammate going idle              | Yes        |
| `TaskCompleted`    | Task marked complete                        | Yes        |
| `ConfigChange`     | Config file changes during session          | Yes        |
| `WorktreeCreate`   | Worktree being created                      | Yes        |
| `WorktreeRemove`   | Worktree being removed                      | No         |

To block from `PreToolUse`, return `hookSpecificOutput.permissionDecision: "deny"`. To block from `Stop`/`PostToolBatch`/etc., return `decision: "block"`.

### Custom tools

```python
# Python
@tool("my_tool", "Description", {"param": str})
async def my_tool(args):
    return {"content": [{"type": "text", "text": f"Result: {args['param']}"}]}

server = create_sdk_mcp_server(name="my-server", tools=[my_tool])
options = ClaudeAgentOptions(mcp_servers={"srv": server}, allowed_tools=["mcp__srv__my_tool"])
```

```typescript
// TypeScript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myTool = tool("my_tool", "Description", { param: z.string() },
  async ({ param }) => ({ content: [{ type: "text", text: `Result: ${param}` }] })
);
const server = createSdkMcpServer({ name: "my-server", tools: [myTool] });
```

MCP tool names follow `mcp__<server-name>__<tool-name>`. Use wildcard `mcp__srv__*` to allow all tools from a server.

### MCP server configuration types

| Config type          | Use                                                    | Key fields                                |
| :------------------- | :----------------------------------------------------- | :---------------------------------------- |
| `stdio` (default)    | Subprocess via stdin/stdout                            | `command`, `args`, `env`                  |
| `sse`                | Server-Sent Events remote server                       | `type: "sse"`, `url`, `headers`           |
| `http`               | HTTP transport remote server                           | `type: "http"`, `url`, `headers`          |
| `sdk`                | In-process MCP server                                  | `type: "sdk"`, created via SDK helpers    |

### Cost tracking

- `total_cost_usd` on `ResultMessage` — client-side estimate for the entire `query()` call
- `modelUsage` / `model_usage` on `ResultMessage` — per-model breakdown
- Per-step usage on each `AssistantMessage` (deduplicate by message ID within a turn)
- **Warning:** these are estimates, not authoritative billing. Use the Usage and Cost API or Console for billing.

### Structured outputs

Pass a JSON Schema to `output_format` / `outputFormat`:

```python
options = ClaudeAgentOptions(
    output_format={"type": "json_schema", "schema": {"type": "object", "properties": {"name": {"type": "string"}}}}
)
```

Result is in `ResultMessage.structured_output`. On validation failure the SDK re-prompts; after the retry limit the result is `error_max_structured_output_retries`.

### Streaming input mode vs single message mode

| Feature                        | Streaming input (recommended)        | Single message                     |
| :----------------------------- | :----------------------------------- | :--------------------------------- |
| Image attachments              | Supported                            | Not supported                      |
| Multi-message queue            | Supported                            | Not supported                      |
| Interrupts                     | Supported (`interrupt()`)            | Not supported                      |
| Hooks                          | Full support                         | Not supported                      |
| Best for                       | Interactive apps, long sessions      | One-shot queries, stateless envs   |

Streaming input: pass an `AsyncGenerator` as the prompt. Python uses `ClaudeSDKClient`; TypeScript uses `query({ prompt: asyncGenerator() })`.

### Claude Code features via `settingSources`

Setting `setting_sources` / `settingSources` controls which filesystem configs load:

| Source      | Location                      | Content                              |
| :---------- | :---------------------------- | :----------------------------------- |
| `"user"`    | `~/.claude/settings.json`     | Global user settings                 |
| `"project"` | `.claude/settings.json`       | Shared project settings + CLAUDE.md  |
| `"local"`   | `.claude/settings.local.json` | Local project settings (gitignored)  |

Pass `[]` to disable all filesystem settings (managed policy always loads regardless). Include `"project"` to load CLAUDE.md, skills, and project-committed hooks.

### Hosting and deployment

- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU minimum
- Requires outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for security isolation
- Sandbox providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox
- `spawnClaudeCodeProcess` option (TS) / `cli_path` option (Python) to run CLI in VMs or remote environments

### File checkpointing

Enable with `enable_file_checkpointing=True` / `enableFileCheckpointing: true`. Then call:
- Python: `await client.rewind_files(user_message_id)`
- TypeScript: `await query.rewindFiles(userMessageId, { dryRun?: true })`

### TypeScript-only `Query` object methods

| Method                       | Description                                                              |
| :--------------------------- | :----------------------------------------------------------------------- |
| `interrupt()`                | Interrupt mid-stream (streaming input mode only)                         |
| `setPermissionMode(mode)`    | Change permission mode mid-session (streaming input only)                |
| `setModel(model)`            | Change model mid-session (streaming input only)                          |
| `applyFlagSettings(settings)` | Merge any setting into flag layer mid-session (streaming input only)    |
| `close()`                    | Forcefully terminate and clean up                                        |
| `rewindFiles(id, opts?)`     | Restore files to state at given user message (requires checkpointing)    |
| `mcpServerStatus()`          | List MCP server connection statuses                                      |
| `setMcpServers(servers)`     | Dynamically replace MCP server set                                       |
| `supportedCommands()`        | Return available slash commands                                          |
| `supportedModels()`          | Return available models                                                  |

### `startup()` (TypeScript) — pre-warm the subprocess

```typescript
const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) { ... }
```

Moves subprocess spawn + initialization out of the first-call critical path.

### Context and compaction

Context accumulates over turns (system prompt, CLAUDE.md, tool definitions, conversation history, tool outputs). When the context window fills, the SDK auto-compacts (summarizes older history). A `compact_boundary` system message is emitted when this happens. To customize:
- Add a "Summary instructions" section to CLAUDE.md
- Use a `PreCompact` hook to archive the full transcript first
- Send `/compact` as a prompt string to trigger manual compaction

### API timeout environment variables

Pass via `env` option:

| Variable                            | Default    | Controls                                                |
| :---------------------------------- | :--------- | :------------------------------------------------------ |
| `API_TIMEOUT_MS`                    | `600000`   | Per-request timeout (ms) on the Anthropic client        |
| `CLAUDE_CODE_MAX_RETRIES`           | `10`       | Maximum API retries per request                         |
| `CLAUDE_ASYNC_AGENT_STALL_TIMEOUT_MS` | `600000` | Stall watchdog for background subagents                 |
| `CLAUDE_ENABLE_STREAM_WATCHDOG`     | Off        | Set to `1` to abort stalled response streams            |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — what the Agent SDK is, capabilities at a glance, comparison with Client SDK/CLI/Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — install, set API key, build a bug-fixing agent end to end
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — turns, messages, tool execution, context window, compaction, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all Options fields, all message types, hook types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full API: `query()`, `ClaudeSDKClient`, `tool()`, `create_sdk_mcp_server()`, `ClaudeAgentOptions`, all types
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use streaming input mode vs one-shot queries
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — partial messages, real-time token streaming
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; session IDs; cross-host resume
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, modes, allow/deny rules, dynamic changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — callback functions, matchers, blocking, modifying inputs, common patterns
- [Subagents](references/claude-code-agent-sdk-subagents.md) — programmatic definition, context isolation, parallelization, `AgentDefinition`
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool`, `createSdkMcpServer`, annotations, error handling, images
- [MCP](references/claude-code-agent-sdk-mcp.md) — MCP server config, transport types, tool search, authentication
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, slash commands, plugins via filesystem
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — preset system prompt, appending, prompt caching across users
- [Skills](references/claude-code-agent-sdk-skills.md) — enabling skills in SDK sessions
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — sending slash commands as prompt strings in SDK sessions
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, validation and retries
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — token usage, `total_cost_usd`, per-model breakdown, caveats
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion`, interactive approvals
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — track file changes, rewind to a prior message
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, debug mode, hook lifecycle events, OpenTelemetry
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container requirements, sandbox providers, production deployment patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading local plugins programmatically via `plugins` option
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate` / `TaskUpdate` tool, task lifecycle
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred MCP tool schema loading with `ToolSearch`
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from `@anthropic-ai/claude-code` / `claude-code-sdk`
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — notes on the removed v2 session API (removed in v0.3.142)

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
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
