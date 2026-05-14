---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — query function, ClaudeAgentOptions, message types, built-in tools, permission modes, hooks, sessions, subagents, MCP, custom tools, streaming, structured outputs, cost tracking, observability, hosting, and secure deployment.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (the Python and TypeScript library for building AI agents with Claude Code's built-in tools, agent loop, and context management).

## Quick Reference

### Installation

| Language   | Package                            | Command                                    |
| :--------- | :--------------------------------- | :----------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`   | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                 | `pip install claude-agent-sdk`             |

The TypeScript SDK bundles a native Claude Code binary; no separate Claude Code install needed.

**Migrating from old SDK?** `@anthropic-ai/claude-code` → `@anthropic-ai/claude-agent-sdk`, `claude-code-sdk` → `claude-agent-sdk`. Only the package name changed; the API is identical.

### Authentication

Set `ANTHROPIC_API_KEY` or use a cloud provider:

| Provider            | Environment variable(s)                                      |
| :------------------ | :----------------------------------------------------------- |
| Anthropic (default) | `ANTHROPIC_API_KEY`                                          |
| Amazon Bedrock      | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials                |
| Claude Platform/AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI    | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials                 |
| Microsoft Azure     | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials              |

### Core API: `query()`

The main entry point. Returns an async generator that streams messages.

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

### Python: `query()` vs `ClaudeSDKClient`

| Feature             | `query()`              | `ClaudeSDKClient`           |
| :------------------ | :--------------------- | :-------------------------- |
| Session             | New each call          | Reuses same session         |
| Conversation        | Single exchange        | Multi-turn, shared context  |
| Interrupts          | Not supported          | Supported                   |
| Use case            | One-off tasks          | Continuous conversations    |

### TypeScript: `startup()` pre-warming

Call `startup()` on boot to pay subprocess initialization cost upfront. Then call `.query()` on the returned `WarmQuery` when a prompt is ready.

### Built-in Tools

| Category          | Tools                                          | What they do                                            |
| :---------------- | :--------------------------------------------- | :------------------------------------------------------ |
| File operations   | `Read`, `Edit`, `Write`                        | Read, modify, and create files                          |
| Search            | `Glob`, `Grep`                                 | Find files by pattern, search content with regex        |
| Execution         | `Bash`                                         | Run shell commands, scripts, git operations             |
| Web               | `WebSearch`, `WebFetch`                        | Search the web, fetch and parse pages                   |
| Discovery         | `ToolSearch`                                   | Dynamically find and load tools on demand               |
| Orchestration     | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite` | Spawn subagents, invoke skills, ask user, track tasks |
| Monitoring        | `Monitor`                                      | Watch background scripts, react to each output line     |

### Permission Modes

| Mode                | Behavior                                                                                   | Use case                                   |
| :------------------ | :----------------------------------------------------------------------------------------- | :----------------------------------------- |
| `default`           | Tools not auto-approved trigger `canUseTool` callback; no callback = deny                 | Custom approval flows                      |
| `acceptEdits`       | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`...)  | Trusted dev workflows                      |
| `plan`              | Read-only; Claude explores and plans without modifying files                               | Planning mode                              |
| `dontAsk`           | Never prompts; everything not in `allowedTools` is denied                                  | Locked-down headless agents                |
| `auto` (TS only)    | Model classifier approves or denies each tool call                                         | Autonomous agents with safety guardrails   |
| `bypassPermissions` | Runs all allowed tools without prompting. Unavailable as root on Unix.                     | CI, containers, fully trusted environments |

### Permission Evaluation Order

1. Hooks (can deny outright)
2. Deny rules (`disallowedTools` / settings.json)
3. Permission mode (`bypassPermissions` approves all that reach here)
4. Allow rules (`allowedTools` / settings.json)
5. `canUseTool` callback (skipped in `dontAsk` mode)

**Key rule:** `allowedTools` does NOT constrain `bypassPermissions`; use `disallowedTools` to block specific tools in that mode.

### Tool Rule Syntax

```
"Read"                   # exact tool name
"Bash(npm *)"            # Bash commands matching glob
"mcp__server__*"         # all tools from an MCP server
```

### Key Options (`ClaudeAgentOptions` / `Options`)

| Option (Python / TypeScript)                  | Description                                                   |
| :-------------------------------------------- | :------------------------------------------------------------ |
| `allowed_tools` / `allowedTools`              | Pre-approved tools (auto-approve without prompting)           |
| `disallowed_tools` / `disallowedTools`        | Always-blocked tools                                          |
| `permission_mode` / `permissionMode`          | Global permission behavior                                    |
| `system_prompt` / `systemPrompt`              | Override system prompt (`"claude_code"` preset or custom string) |
| `max_turns` / `maxTurns`                      | Max tool-use round trips (no limit by default)                |
| `max_budget_usd` / `maxBudgetUsd`             | Stop after spending this amount                               |
| `effort`                                      | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model`                                       | Model ID (defaults to Claude Code's default)                  |
| `mcp_servers` / `mcpServers`                  | External MCP servers to connect                               |
| `agents`                                      | Programmatic subagent definitions                             |
| `hooks`                                       | SDK hook callbacks                                            |
| `setting_sources` / `settingSources`          | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `skills`                                      | Which skills to enable (`"all"`, list of names, or `[]`)      |
| `resume`                                      | Session ID to resume                                          |
| `continue_conversation` / `continue`          | Resume most recent session in directory                       |
| `fork`                                        | Fork a session by ID                                          |
| `cwd`                                         | Working directory for the agent                               |
| `include_partial_messages` / `includePartialMessages` | Stream incremental text/tool-call updates           |
| `output_format` / `outputFormat`              | JSON Schema for structured output                             |
| `can_use_tool` / `canUseTool`                 | Callback for runtime approval of tool calls                   |
| `plugins`                                     | Local plugin directories to load                              |
| `persist_session` / `persistSession` (TS)     | `false` = in-memory only (TypeScript only)                    |

### Message Types

| Type (Python class / TS `type` field) | When emitted                                              | Key fields                                      |
| :------------------------------------ | :-------------------------------------------------------- | :---------------------------------------------- |
| `SystemMessage` / `"system"`          | Session start (`subtype: "init"`) and compaction boundary | `session_id` (TS: on init; Python: in `.data`)  |
| `AssistantMessage` / `"assistant"`    | After each Claude response turn                           | `content` (text + tool call blocks)             |
| `UserMessage` / `"user"`              | After each tool execution                                 | Tool result content                             |
| `StreamEvent` / `"stream_event"`      | When partial messages enabled; raw API streaming events   | `event` dict with type/delta                    |
| `ResultMessage` / `"result"`          | End of agent loop                                         | `subtype`, `result`, `total_cost_usd`, `session_id` |

**Python:** check with `isinstance(message, ResultMessage)`.
**TypeScript:** check with `message.type === "result"`. Content blocks are at `message.message.content`.

### Result Subtypes

| Subtype                              | Meaning                                            | `result` field? |
| :----------------------------------- | :------------------------------------------------- | :-------------: |
| `success`                            | Task completed normally                            | Yes             |
| `error_max_turns`                    | Hit `maxTurns` limit                               | No              |
| `error_max_budget_usd`               | Hit `maxBudgetUsd` limit                           | No              |
| `error_during_execution`             | API failure or cancelled request                   | No              |
| `error_max_structured_output_retries`| Structured output validation failed               | No              |

All subtypes include `total_cost_usd`, `usage`, `num_turns`, `session_id`.

### Effort Levels

| Level    | Best for                                         |
| :------- | :----------------------------------------------- |
| `"low"`  | File lookups, listing directories                |
| `"medium"` | Routine edits, standard tasks                  |
| `"high"` | Refactors, debugging (TypeScript SDK default)    |
| `"xhigh"` | Coding/agentic tasks; recommended on Opus 4.7  |
| `"max"`  | Multi-step deep analysis                         |

### Sessions

| Approach                          | How                                     | Use when                             |
| :-------------------------------- | :-------------------------------------- | :----------------------------------- |
| Automatic (Python `ClaudeSDKClient`) | Each `client.query()` continues session | Multi-turn in one process           |
| Continue (most recent)            | `continue=True` / `continue: true`      | Resume after process restart         |
| Resume (specific session)         | `resume=session_id`                     | Multiple sessions or non-recent ones |
| Fork                              | `fork=session_id`                       | Try alternative without losing original |

Capture `session_id` from `ResultMessage.session_id` (or init `SystemMessage` in TypeScript).

### Hooks

Hooks run in your application process, not in the agent's context window.

| Hook                           | When it fires                          | Common uses                                 |
| :----------------------------- | :------------------------------------- | :------------------------------------------ |
| `PreToolUse`                   | Before a tool executes                 | Validate inputs, block dangerous commands   |
| `PostToolUse`                  | After a tool returns                   | Audit outputs, trigger side effects         |
| `UserPromptSubmit`             | When a prompt is sent                  | Inject additional context into prompts      |
| `Stop`                         | When the agent finishes                | Validate result, save state                 |
| `SubagentStart` / `SubagentStop` | When a subagent spawns/completes     | Track parallel task results                 |
| `PreCompact`                   | Before context compaction              | Archive full transcript before summarizing  |
| `PermissionRequest`            | When Claude awaits permission          | Send Slack/email notifications              |

Hook matchers use regex patterns against the tool name (e.g., `"Write|Edit"`). Return `{}` to allow, or include `permissionDecision: "deny"` to block.

**Python:** `HookMatcher(matcher="Edit|Write", hooks=[callback])`
**TypeScript:** `{ matcher: "Edit|Write", hooks: [callback] }`

### Subagents (SDK Programmatic Definition)

Define via the `agents` option. Include `"Agent"` in `allowedTools`.

```python
AgentDefinition(
    description="When to use this agent (Claude reads this)",
    prompt="System prompt / instructions for this agent",
    tools=["Read", "Glob", "Grep"],  # restrict to these tools
)
```

Benefits: context isolation (fresh conversation per invocation), parallelization, specialized instructions.

### MCP Servers

| Transport | Config keys                 | Example                                              |
| :-------- | :-------------------------- | :--------------------------------------------------- |
| stdio     | `command`, `args`, `env`    | `{"command": "npx", "args": ["@playwright/mcp@latest"]}` |
| HTTP/SSE  | `type: "http"`, `url`       | `{"type": "http", "url": "https://example.com/mcp"}` |
| In-process | `createSdkMcpServer()`     | Custom tools in same process                         |

Allow MCP tools with `allowedTools: ["mcp__server-name__tool-name"]` or `"mcp__server-name__*"` for all.

Tool search is on by default (disabled on Vertex AI): defers MCP tool schemas until needed, improving context efficiency.

### Custom Tools

**Python:** use `@tool` decorator, wrap with `create_sdk_mcp_server`, pass to `mcp_servers`.
**TypeScript:** use `tool()` function, wrap with `createSdkMcpServer`, pass to `mcpServers`.

Tool handler must return: `{ content: [{ type: "text", text: "..." }], isError?: bool }`.

Set `readOnlyHint: true` in tool annotations to allow parallel execution.

### Streaming Output

Enable with `include_partial_messages=True` (Python) / `includePartialMessages: true` (TypeScript).

Filter for `StreamEvent` messages, then check `event.type === "content_block_delta"` and `delta.type === "text_delta"` for live text chunks.

### Input Modes

- **Streaming input** (recommended): pass `AsyncGenerator` as prompt for multi-turn interactive sessions
- **Single message**: pass a string prompt for one-shot queries

### Structured Outputs

Pass a JSON Schema to `output_format` (Python) / `outputFormat` (TypeScript). The agent can use any tools, then the SDK validates output and places it in `result.structured_output`. Failure returns `error_max_structured_output_retries`.

Use Zod (TypeScript) or Pydantic (Python) for type-safe schemas.

### Cost Tracking

Cost data on `ResultMessage`: `total_cost_usd` (Python) / `costUSD` or `total_cost_usd` (TypeScript). Per-step usage on each `AssistantMessage`.

**Important:** `total_cost_usd` is a client-side estimate, not authoritative billing. Use the [Usage and Cost API](https://platform.claude.com/docs/en/build-with-claude/usage-cost-api) for billing decisions.

Per-model breakdown available as `model_usage` (Python) / `modelUsage` (TypeScript) on the result.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` and at least one exporter:

| Signal  | Enable with                                                        |
| :------ | :----------------------------------------------------------------- |
| Metrics | `OTEL_METRICS_EXPORTER=otlp`                                       |
| Logs    | `OTEL_LOGS_EXPORTER=otlp`                                          |
| Traces  | `OTEL_TRACES_EXPORTER=otlp` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` |

Pass env vars via `options.env` (per-call) or set in the process environment (recommended for production). In TypeScript, `env` replaces the inherited environment — include `...process.env`.

### System Prompt Customization

| Starting point        | How to set                                            | When to use                                         |
| :-------------------- | :---------------------------------------------------- | :-------------------------------------------------- |
| Minimal default       | Omit `systemPrompt`                                   | Thin tool-calling loops                             |
| `claude_code` preset  | `{ type: "preset", preset: "claude_code" }`           | CLI/IDE-like coding tools                           |
| Preset + append       | Add `append: "your instructions"` to preset object   | Coding tools with additional product rules          |
| Custom string         | Pass a string                                         | Different surface, identity, or permission model    |

CLAUDE.md files (loaded via `settingSources`) inject project context alongside whichever system prompt is chosen.

### Setting Sources

Control which filesystem settings load with `setting_sources` (Python) / `settingSources` (TypeScript):

| Source      | Loads from                    |
| :---------- | :---------------------------- |
| `"user"`    | `~/.claude/`                  |
| `"project"` | `./.claude/` in `cwd`         |
| `"local"`   | `./.claude/` local overrides  |

Pass `[]` to disable all filesystem settings (programmatic config only). Managed policy and global `~/.claude.json` always load regardless.

### File Checkpointing

Enable with `file_checkpointing=True` (Python) / `fileCheckpointing: true` (TypeScript). Tracks Write/Edit/NotebookEdit changes. Capture checkpoint UUIDs from `UserMessage`s. Call `rewind_files(session_id, checkpoint_uuid)` (Python) or `rewindFiles(...)` (TypeScript) to restore.

Note: only tracks tool-based changes. Bash-driven file changes (`echo > file`) are not captured.

### Hosting Requirements

- Python 3.10+ or Node.js 18+
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production

Sandbox providers: Modal, Cloudflare Sandboxes, Daytona, E2B, Fly Machines, Vercel Sandbox.

### Secure Deployment Key Principles

- **Isolation**: run agent in a container separate from sensitive resources
- **Least privilege**: mount only needed directories; restrict network to specific endpoints
- **Credential proxy**: inject API keys outside agent boundary (agent never sees the key)
- **Deny rules**: use `disallowedTools` to block dangerous operations regardless of mode
- **Web search summarization**: built-in; reduces prompt injection risk from web content

### Skills in the SDK

Skills must be filesystem artifacts (`SKILL.md` files). Not available via programmatic API.

Loaded via `settingSources`. Control with `skills` option: `"all"`, list of names, or `[]`.

### Slash Commands in the SDK

Send as strings in the prompt. Available commands listed in the `system/init` message (`message.slash_commands`).

Common commands: `/compact` (manual compaction), `/context`, `/usage`.

### Todo Tracking

`TodoWrite` is the current default. New Task tools available behind `CLAUDE_CODE_ENABLE_TASKS=1`.

Todo lifecycle: `pending` → `in_progress` → completed → removed.

### Tool Search

On by default (off on Vertex AI and non-first-party `ANTHROPIC_BASE_URL`). Defers MCP tool schemas until needed.

Override via `ENABLE_TOOL_SEARCH` env var: `true` (force on), `false` (force off), `auto` (activate when tool defs exceed 10% of context), `auto:N` (custom threshold).

Requires Claude Sonnet 4+ or Opus 4+. Haiku not supported.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step first agent, key concepts summary
- [How the Agent Loop Works](references/claude-code-agent-sdk-agent-loop.md) — loop lifecycle, message types, turns, context window, compaction, sessions
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — complete TypeScript API reference: `query()`, `startup()`, `tool()`, `Options`, all message types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — complete Python API reference: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types
- [Hooks](references/claude-code-agent-sdk-hooks.md) — hook events, matchers, callback API, block/allow/modify patterns
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; automatic session management; cross-host resumption
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, evaluation order, settings.json integration
- [Subagents](references/claude-code-agent-sdk-subagents.md) — programmatic subagent definitions, AgentDefinition fields, parallelization, context isolation
- [MCP](references/claude-code-agent-sdk-mcp.md) — transport types (stdio, HTTP/SSE, in-process), tool search, authentication, error handling
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — define tools with schemas and handlers, createSdkMcpServer, annotations, error handling, images
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — enable partial messages, handle StreamEvent, live text/tool-call updates
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — streaming input mode vs single message input, when to use each
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod/Pydantic, validation, error handling
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — token usage fields, per-step vs cumulative, multi-session tracking
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry configuration, metrics/logs/traces, backend integration
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container requirements, resource allocation, sandbox providers, deployment patterns
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — threat model, isolation, least privilege, credential management, network controls
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — preset vs custom prompt, CLAUDE.md, append, output styles
- [Claude Code Features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — settingSources, CLAUDE.md, skills, hooks, slash commands, plugins
- [Handle User Input](references/claude-code-agent-sdk-user-input.md) — canUseTool callback, permission approvals, AskUserQuestion, defer pattern
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — programmatic vs filesystem-based subagents, AgentDefinition, parallelization
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — filesystem-based skills, settingSources, the `skills` option
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — discovering and sending slash commands, /compact, /context
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — TodoWrite lifecycle, monitoring todo changes, Task tools migration
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — how tool search works, configuration, ENABLE_TOOL_SEARCH values, optimization
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — enable checkpointing, capture UUIDs, rewindFiles API
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — load local plugins, skills/agents/hooks/MCP servers in plugins
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — upgrading from `@anthropic-ai/claude-code` / `claude-code-sdk` to the new package names
- [TypeScript V2 Session API (deprecated)](references/claude-code-agent-sdk-typescript-v2-preview.md) — legacy V2 API reference; use V1 `query()` instead

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the Agent Loop Works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code Features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
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
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming Output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 Session API (deprecated): https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
