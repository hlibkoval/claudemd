---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building AI agents in Python and TypeScript with the agent loop, sessions, permissions, hooks, subagents, MCP, custom tools, streaming, structured outputs, observability, and hosting.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly the Claude Code SDK).

## Quick Reference

### Installation

| Language   | Package                              | Command                                      |
| :--------- | :----------------------------------- | :------------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`               |

Set `ANTHROPIC_API_KEY` before running. Also supports `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1` for third-party providers.

**Migration from old SDK:**

| Aspect               | Old                         | New                              |
| :------------------- | :-------------------------- | :------------------------------- |
| TypeScript package   | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package       | `claude-code-sdk`           | `claude-agent-sdk`               |
| Python import        | `claude_code_sdk`           | `claude_agent_sdk`               |

### Core `query()` Function

The primary entry point in both SDKs:

```python
# Python
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
// TypeScript
for await (const message of query({ prompt: "...", options: { ... } })) {
  ...
}
```

### Built-in Tools

| Tool              | What it does                                                        |
| :---------------- | :------------------------------------------------------------------ |
| `Read`            | Read files in the working directory                                 |
| `Write`           | Create new files                                                    |
| `Edit`            | Make precise edits to existing files                                |
| `Bash`            | Run terminal commands, scripts, git operations                      |
| `Monitor`         | Watch a background script and react to each output line             |
| `Glob`            | Find files by pattern (`**/*.ts`, `src/**/*.py`)                    |
| `Grep`            | Search file contents with regex                                     |
| `WebSearch`       | Search the web for current information                              |
| `WebFetch`        | Fetch and parse web page content                                    |
| `ToolSearch`      | Dynamically find and load tools on-demand                           |
| `Agent`           | Spawn subagents for focused subtasks                                |
| `Skill`           | Invoke skills                                                       |
| `AskUserQuestion` | Ask the user clarifying questions with multiple choice options      |
| `TodoWrite`       | Track tasks during the session                                      |

### ClaudeAgentOptions / Options Key Fields

| Python field            | TypeScript field          | Description                                         |
| :---------------------- | :------------------------ | :-------------------------------------------------- |
| `allowed_tools`         | `allowedTools`            | List of pre-approved tools (no prompt required)     |
| `disallowed_tools`      | `disallowedTools`         | Tools to block unconditionally                      |
| `permission_mode`       | `permissionMode`          | Global permission behavior (see modes below)        |
| `system_prompt`         | `systemPrompt`            | Override system prompt                              |
| `model`                 | `model`                   | Model ID (e.g. `claude-sonnet-4-6`)                 |
| `max_turns`             | `maxTurns`                | Max tool-use round trips before stopping            |
| `max_budget_usd`        | `maxBudgetUsd`            | Max cost before stopping                            |
| `effort`                | `effort`                  | Reasoning depth: `low`, `medium`, `high`, `xhigh`, `max` |
| `mcp_servers`           | `mcpServers`              | External MCP server configs                         |
| `hooks`                 | `hooks`                   | Callback hooks for agent lifecycle events           |
| `agents`                | `agents`                  | Subagent definitions                                |
| `resume`                | `resume`                  | Resume a previous session by ID                     |
| `fork_session`          | `forkSession`             | Fork the resumed session                            |
| `continue_conversation` | `continue`                | Resume the most recent session in current directory |
| `setting_sources`       | `settingSources`          | Which config sources to load (`project`, `user`)    |
| `cwd`                   | `cwd`                     | Working directory for the agent                     |
| `output_format`         | `outputFormat`            | Structured output schema (JSON Schema/Pydantic/Zod) |
| `include_partial_messages` | `includePartialMessages` | Enable real-time streaming events                |
| `persist_session`       | `persistSession`          | Write session to disk (TypeScript only; default true) |
| `env`                   | `env`                     | Environment variables for the CLI subprocess        |

### Permission Modes

| Mode                | Behavior                                                                        | Use case                              |
| :------------------ | :------------------------------------------------------------------------------ | :------------------------------------ |
| `default`           | No auto-approvals; unmatched tools trigger `canUseTool` callback                | Interactive apps                      |
| `acceptEdits`       | Auto-approves file edits and common filesystem commands (`mkdir`, `mv`, etc.)   | Trusted dev workflows                 |
| `plan`              | Read-only tools only; Claude analyzes without editing                           | Plan before acting                    |
| `dontAsk`           | Denies anything not in `allowedTools`; never calls `canUseTool`                 | Locked-down headless agents           |
| `auto` (TS only)    | Model classifier approves or denies each tool call                              | Autonomous agents with safety guards  |
| `bypassPermissions` | Runs all tools without any prompts (cannot be used as root on Unix)             | Sandboxed CI/containers only          |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback

### Message Types

| Type (Python class)  | `type` field (TS)  | When it appears                                         |
| :------------------- | :----------------- | :------------------------------------------------------ |
| `SystemMessage`      | `"system"`         | Session init (`subtype: "init"`) and compaction events  |
| `AssistantMessage`   | `"assistant"`      | After each Claude response turn                         |
| `UserMessage`        | `"user"`           | After each tool execution with the tool result          |
| `StreamEvent`        | `"stream_event"`   | Real-time tokens/events (requires `includePartialMessages`) |
| `ResultMessage`      | `"result"`         | End of the agent loop; final result + cost + session ID |

### ResultMessage Subtypes

| Subtype                              | `result` available? | Meaning                                          |
| :----------------------------------- | :-----------------: | :----------------------------------------------- |
| `success`                            | Yes                 | Task completed normally                          |
| `error_max_turns`                    | No                  | Hit `maxTurns` limit                             |
| `error_max_budget_usd`               | No                  | Hit `maxBudgetUsd` limit                         |
| `error_during_execution`             | No                  | API failure or cancelled request                 |
| `error_max_structured_output_retries`| No                  | Structured output validation failed              |

`ResultMessage` always carries `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Sessions

| Approach                        | How                                              | When to use                                       |
| :------------------------------ | :----------------------------------------------- | :------------------------------------------------ |
| Single query                    | Plain `query()`                                  | One-shot tasks                                    |
| Multi-turn (Python)             | `ClaudeSDKClient` (async context manager)        | Continuous conversations in same process          |
| Multi-turn (TypeScript)         | `continue: true` on each subsequent `query()`    | Continuous conversations in same process          |
| Resume specific session         | `resume=session_id`                              | Specific prior session by ID                      |
| Resume most recent              | `continue_conversation=True` / `continue: true`  | After process restart, continue most recent       |
| Fork                            | `resume=session_id, fork_session=True`           | Explore alternative approach without losing original |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `encoded-cwd` replaces non-alphanumeric chars with `-`.

### Hooks

Available hook events:

| Hook Event           | Python | TypeScript | Trigger                                  | Common use                              |
| :------------------- | :----: | :--------: | :--------------------------------------- | :-------------------------------------- |
| `PreToolUse`         | Yes    | Yes        | Before a tool executes                   | Block dangerous commands                |
| `PostToolUse`        | Yes    | Yes        | After a tool returns                     | Audit outputs, trigger side effects     |
| `PostToolUseFailure` | Yes    | Yes        | Tool execution failure                   | Handle or log tool errors               |
| `PostToolBatch`      | No     | Yes        | All tool calls in a batch resolve        | Inject conventions once per batch       |
| `UserPromptSubmit`   | Yes    | Yes        | User prompt submitted                    | Inject additional context               |
| `Stop`               | Yes    | Yes        | Agent finishes                           | Save session state                      |
| `SubagentStart`      | Yes    | Yes        | Subagent spawns                          | Track parallel tasks                    |
| `SubagentStop`       | Yes    | Yes        | Subagent completes                       | Aggregate results                       |
| `PreCompact`         | Yes    | Yes        | Before context compaction                | Archive full transcript                 |
| `PermissionRequest`  | Yes    | Yes        | Permission dialog would show             | Custom permission handling              |
| `SessionStart`       | No     | Yes        | Session initialization                   | Initialize logging/telemetry            |
| `SessionEnd`         | No     | Yes        | Session termination                      | Clean up resources                      |
| `Notification`       | Yes    | Yes        | Agent status messages                    | Forward to Slack/PagerDuty              |
| `Setup`              | No     | Yes        | Session setup/maintenance                | Run initialization tasks                |
| `TeammateIdle`       | No     | Yes        | Teammate becomes idle                    | Reassign work                           |
| `TaskCompleted`      | No     | Yes        | Background task completes                | Aggregate parallel results              |
| `ConfigChange`       | No     | Yes        | Configuration file changes               | Reload settings dynamically             |
| `WorktreeCreate`     | No     | Yes        | Git worktree created                     | Track isolated workspaces               |
| `WorktreeRemove`     | No     | Yes        | Git worktree removed                     | Clean up workspace resources            |

Hook callbacks receive `(input_data, tool_use_id, context)`. Return `{}` to allow, or `{"hookSpecificOutput": {"hookEventName": ..., "permissionDecision": "deny"}}` to block.

Hook `matcher` is a regex matched against tool name (e.g. `"Write|Edit"`). MCP tools: `mcp__<server>__<action>`.

### Subagents

Define via `agents` option with `AgentDefinition` / plain object. Requires `Agent` in `allowedTools`.

```python
AgentDefinition(
    description="When to use this subagent",  # Claude reads this to decide
    prompt="Subagent system prompt",
    tools=["Read", "Glob", "Grep"],
    effort="high",          # optional effort override
    model="claude-...",     # optional model override
)
```

Each subagent runs in a fresh conversation context. Only its final response returns to the parent. Use subagents to isolate context, parallelize tasks, or apply specialized instructions.

### MCP Servers

Configure via `mcp_servers` / `mcpServers` option:

```python
# Stdio server
{"playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}}

# HTTP server
{"docs": {"type": "http", "url": "https://example.com/mcp"}}
```

Allow MCP tools with wildcard: `allowedTools: ["mcp__playwright__*"]`

Use `ToolSearch` tool to load MCP tools on-demand instead of preloading all (reduces context cost).

### Custom Tools

Define with `@tool` decorator (Python) or `tool()` function (TypeScript). Wrap in `create_sdk_mcp_server` / `createSdkMcpServer`, pass to `mcpServers`.

Handler must return `{"content": [{"type": "text", "text": "..."}], ...}`. Set `isError: true` for failures (Claude reacts rather than stopping). Set `readOnlyHint: true` in annotations to enable parallel execution.

### Structured Outputs

Pass `output_format` / `outputFormat` with a JSON Schema, Pydantic model (Python), or Zod schema (TypeScript). The `ResultMessage` includes a `structured_output` field with validated data. On validation failure after retries, result subtype is `error_max_structured_output_retries`.

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true` to receive `StreamEvent` messages with raw API events as they stream. Filter for `content_block_delta` events where `delta.type === "text_delta"` to extract text chunks.

### Effort Levels

| Level    | Behavior              | Good for                                     |
| :------- | :-------------------- | :------------------------------------------- |
| `low`    | Minimal reasoning     | File lookups, listing directories            |
| `medium` | Balanced reasoning    | Routine edits, standard tasks                |
| `high`   | Thorough analysis     | Refactors, debugging (TypeScript default)    |
| `xhigh`  | Extended reasoning    | Coding tasks; recommended on Opus 4.7        |
| `max`    | Maximum reasoning     | Multi-step problems requiring deep analysis  |

Python default: model's own default. TypeScript default: `high`.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus at least one exporter. Three independent signals:

| Signal     | Enable variable              | What it contains                                      |
| :--------- | :--------------------------- | :---------------------------------------------------- |
| Metrics    | `OTEL_METRICS_EXPORTER`      | Token/cost counters, session counts, tool decisions   |
| Log events | `OTEL_LOGS_EXPORTER`         | Per-prompt, API request, API error, tool result       |
| Traces     | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Spans per model request, tool call, hook |

Pass via `env` dict in options, or set in the process environment before startup.

### Hosting

- Requires 1 GiB RAM, 5 GiB disk, 1 CPU (adjust per task)
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production
- Sandbox providers: Modal, Cloudflare Sandboxes, Daytona, E2B, Fly Machines, Vercel Sandbox

### TypeScript-only: `startup()`

Pre-warms the CLI subprocess before a prompt is ready:

```typescript
const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) { ... }
```

### Python-only: `ClaudeSDKClient`

Manages session state automatically across multiple calls:

```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("First prompt")
    async for message in client.receive_response():
        ...
    await client.query("Follow-up using same context")
    async for message in client.receive_response():
        ...
```

Supports `await client.set_permission_mode("acceptEdits")` to change mode mid-session.

### Context Window Management

- Context accumulates across turns: prompts, tool inputs, tool outputs, responses
- Automatic compaction when context approaches limit; emits `compact_boundary` system event
- `CLAUDE.md` loaded via `settingSources` is re-injected on every request (survives compaction)
- Use subagents for long subtasks; they start with fresh context
- Use `ToolSearch` to avoid loading all MCP tools upfront

### Claude Code Features via `settingSources`

| Feature        | Description                         | Location                           |
| :------------- | :---------------------------------- | :--------------------------------- |
| Skills         | Specialized capabilities in Markdown | `.claude/skills/*/SKILL.md`        |
| Slash commands | Custom commands for common tasks    | `.claude/commands/*.md`            |
| Memory         | Project context and instructions    | `CLAUDE.md` or `.claude/CLAUDE.md` |
| Plugins        | Commands, agents, MCP servers       | Programmatic via `plugins` option  |

`settingSources` values: `"project"` (loads from CWD), `"user"` (loads from `~/.claude/`). Default `query()` loads both.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK capabilities, built-in tools, comparison to Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — build a bug-fixing agent end-to-end, key concepts, permission modes
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, context window, sessions, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — complete API: `query()`, `startup()`, `tool()`, `Options`, all message types, hooks types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — complete API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, hooks types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; cross-host session handling; `listSessions`, `getSessionMessages`
- [Permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission mode details, dynamic mode changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, matchers, callback API, outputs, blocking tool calls
- [Subagents](references/claude-code-agent-sdk-subagents.md) — AgentDefinition config, context isolation, parallelization, what subagents inherit
- [MCP](references/claude-code-agent-sdk-mcp.md) — transport types, tool search, authentication, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — defining tools, tool annotations, error handling, returning images/resources
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — enable partial messages, handle StreamEvent, text delta extraction
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — input modes comparison
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, error handling
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — token usage fields, per-step vs. cumulative, model usage breakdown
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, log events, configuration
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — settingSources, CLAUDE.md, skills, slash commands, plugins
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — system prompt customization
- [Skills](references/claude-code-agent-sdk-skills.md) — skills in the SDK context
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — slash commands in the SDK
- [Plugins](references/claude-code-agent-sdk-plugins.md) — plugins option
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert file changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — TodoWrite tool usage
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — ToolSearch for on-demand tool loading
- [Hosting](references/claude-code-agent-sdk-hosting.md) — production deployment, container sandboxing, sandbox providers
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — deprecated V2 session API notes
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from claude-code-sdk / @anthropic-ai/claude-code

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
