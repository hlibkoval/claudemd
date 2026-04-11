---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK - the Python and TypeScript library for building production AI agents powered by Claude. Covers the agent loop, query API, tools, permissions, hooks, subagents, MCP, sessions, skills, slash commands, custom tools, streaming, structured outputs, cost tracking, observability, hosting, secure deployment, and migration from the old Claude Code SDK. Use this skill when writing or debugging code that imports claude_agent_sdk (Python) or @anthropic-ai/claude-agent-sdk (TypeScript), building autonomous agents with Claude, or answering questions about the Agent SDK. Note: this covers the Agent SDK library for building your own agents - it is NOT the same as Claude Code (the CLI tool).
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — Anthropic's Python and TypeScript library for building production AI agents powered by Claude. The SDK embeds the same agent loop, built-in tools, and context management that power Claude Code, exposed as a programmable library.

Important: The Claude Code SDK was renamed to the **Claude Agent SDK**. Package names changed from `@anthropic-ai/claude-code` / `claude-code-sdk` to `@anthropic-ai/claude-agent-sdk` / `claude-agent-sdk`. This skill documents the Agent SDK (the library for building agents), not the Claude Code CLI tool.

## Quick Reference

### Installation and entry points

| Language | Install | Import |
| --- | --- | --- |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | `import { query } from "@anthropic-ai/claude-agent-sdk"` |
| Python | `pip install claude-agent-sdk` (or `uv add claude-agent-sdk`) | `from claude_agent_sdk import query, ClaudeAgentOptions` |

Authentication: set `ANTHROPIC_API_KEY`, or one of `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, `CLAUDE_CODE_USE_FOUNDRY=1` for Bedrock, Vertex AI, or Azure Foundry.

### Core API

The primary entry point is `query()`, an async iterator that streams messages as the agent runs. Python also provides `ClaudeSDKClient` for stateful multi-turn sessions. TypeScript V2 preview introduces `createSession()` / `resumeSession()` / `session.send()` / `session.stream()` as an alternative to generator-based code.

```python
# Python
async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

```typescript
// TypeScript
for await (const message of query({
  prompt: "Find and fix the bug in auth.py",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

### The agent loop

Every session runs the same cycle:

1. SDK yields `SystemMessage` (subtype `"init"`) with session metadata.
2. Claude evaluates state and responds — either with text, tool calls, or both (`AssistantMessage`).
3. SDK executes each tool call, feeds results back (`UserMessage` for tool results).
4. Loop repeats until Claude produces a response with no tool calls.
5. SDK yields a final `AssistantMessage` then a `ResultMessage` with text, usage, cost, and session id.

A "turn" is one round trip: Claude output + tool execution. Cap with `max_turns` / `maxTurns` or `max_budget_usd` / `maxBudgetUsd`.

### Message types

| Type | When | Notes |
| --- | --- | --- |
| `SystemMessage` | Session init and compact boundary | `subtype: "init"` carries session metadata |
| `AssistantMessage` | Each Claude response | Contains text and tool call blocks |
| `UserMessage` | After each tool execution | Carries tool result content |
| `StreamEvent` | Only with partial messages enabled | Raw API deltas for live streaming |
| `ResultMessage` | Always last | Final text, usage, cost, session_id, subtype |

TypeScript checks `message.type === "assistant"` etc; Python uses `isinstance(message, AssistantMessage)`. In TypeScript, `AssistantMessage` / `UserMessage` wrap the API payload in `.message`, so content is at `message.message.content`.

### ResultMessage subtypes

| Subtype | Meaning | `result` field present |
| --- | --- | --- |
| `success` | Task finished normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API or runtime error interrupted the loop | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, `session_id`, and `stop_reason` (`end_turn`, `max_tokens`, `refusal`, etc.).

### Built-in tools

| Category | Tools |
| --- | --- |
| File operations | `Read`, `Edit`, `Write` |
| Search | `Glob`, `Grep` |
| Execution | `Bash` |
| Web | `WebSearch`, `WebFetch` |
| Discovery | `ToolSearch` (load tools on demand) |
| Orchestration | `Agent` (subagents), `Skill`, `AskUserQuestion`, `TodoWrite` |
| Background | `Monitor` (watch long-running scripts) |

Read-only tools run in parallel; state-modifying tools run sequentially. Mark custom tools `readOnly` (TypeScript) / `readOnlyHint` (Python) to allow parallel execution.

### Permissions

Evaluation order when a tool is requested:

1. **Hooks** — can allow, deny, or fall through.
2. **Deny rules** (from `disallowed_tools` + `settings.json`) — block even in `bypassPermissions`.
3. **Permission mode** — `bypassPermissions` approves; `acceptEdits` approves file ops; others fall through.
4. **Allow rules** (from `allowed_tools` + `settings.json`) — approve if matched.
5. **`canUseTool` callback** — runtime decision; skipped in `dontAsk` (denies instead).

Permission modes:

| Mode | Behavior |
| --- | --- |
| `default` | Unmatched tools trigger `canUseTool`; no callback means deny |
| `acceptEdits` | Auto-approves Edit/Write and filesystem commands (`mkdir`, `touch`, `rm`, `mv`, `cp`, `sed`) inside working directory |
| `plan` | No tool execution; Claude produces a plan only |
| `dontAsk` | Anything not pre-approved is denied; `canUseTool` never called |
| `bypassPermissions` | Runs everything unless denied by rules/hooks; cannot run as root on Unix |
| `auto` (TS only) | Model classifier approves or denies each call |

Warning: `allowed_tools` does NOT constrain `bypassPermissions` — unlisted tools still run. Use `disallowed_tools` to block tools in bypass mode.

Rule syntax supports scoping like `"Bash(npm:*)"`. Change mode mid-session with `set_permission_mode()` / `setPermissionMode()`.

### Key ClaudeAgentOptions fields

| Field (Python / TypeScript) | Purpose |
| --- | --- |
| `allowed_tools` / `allowedTools` | Auto-approve list |
| `disallowed_tools` / `disallowedTools` | Hard deny list |
| `permission_mode` / `permissionMode` | Global mode (see above) |
| `system_prompt` / `systemPrompt` | Custom system prompt (string or `{ type: "preset", preset: "claude_code", append?: ... }`) |
| `setting_sources` / `settingSources` | Load filesystem settings: `"user"`, `"project"`, `"local"` (none by default) |
| `max_turns` / `maxTurns` | Cap tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | Cap spend |
| `effort` | `"low"`, `"medium"`, `"high"`, `"max"` reasoning depth |
| `model` | e.g. `"claude-sonnet-4-6"` |
| `cwd` | Working directory |
| `hooks` | Hook callback registration |
| `mcp_servers` / `mcpServers` | MCP server configs |
| `agents` | Subagent definitions |
| `plugins` | Plugin configs |
| `resume` | Session id to resume |
| `include_partial_messages` / `includePartialMessages` | Enable `StreamEvent` delta streaming |
| `can_use_tool` / `canUseTool` | Interactive approval callback |

### Hooks

Hooks are Python or TypeScript callbacks that run inside your process (not in Claude's context) at key lifecycle points:

| Hook | Fires | Common use |
| --- | --- | --- |
| `PreToolUse` | Before tool executes | Validate, block, transform inputs |
| `PostToolUse` | After tool returns | Audit, side effects |
| `UserPromptSubmit` | On prompt submission | Inject context |
| `Stop` / `SubagentStop` | When agent or subagent finishes | Validate output, save state |
| `SessionStart` / `SessionEnd` | Session lifecycle | Initialization/teardown |
| `SubagentStart` | When subagent spawns | Track child tasks |
| `PreCompact` | Before context compaction | Archive transcript; receives `trigger: manual or auto` |
| `Notification` / `PreCompact` / etc | Additional TypeScript-only events | See typescript reference |

Register via `hooks={"PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[callback])]}`. Hook callbacks return `{}` to continue, or a decision object to allow/deny/modify.

### Subagents

Spawn specialized agents via the `Agent` tool. Include `"Agent"` in `allowedTools`. Define them with `AgentDefinition`:

```python
agents={
    "code-reviewer": AgentDefinition(
        description="Expert code reviewer.",
        prompt="Analyze code quality and suggest improvements.",
        tools=["Read", "Glob", "Grep"],
    )
}
```

Each subagent starts with a fresh conversation (no parent history), loads its own system prompt and project CLAUDE.md, and returns only its final response to the parent. Messages from inside a subagent include `parent_tool_use_id`. Subagents inherit `bypassPermissions` and cannot override it.

### MCP (Model Context Protocol)

Connect external services (databases, browsers, APIs). The SDK supports stdio, SSE, HTTP, and in-process SDK MCP servers created with `createSdkMcpServer()` / `create_sdk_mcp_server()`.

```python
mcp_servers={
    "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}
}
```

Use `ToolSearch` / MCP tool search to load MCP tool schemas on demand rather than preloading every schema into the context window.

### Custom tools

Define in-process custom tools with `@tool` (Python) or `tool()` (TypeScript) and register them via `createSdkMcpServer()`. Custom tools default to sequential execution; mark `readOnly` / `readOnlyHint` for parallelism.

### Sessions

Capture `ResultMessage.session_id` to resume later. TypeScript exposes it directly on the init `SystemMessage`; Python nests it in `SystemMessage.data["session_id"]`. Resume with `options.resume = sessionId` to restore full context. Python's `ClaudeSDKClient` handles session ids automatically. Sessions can also be forked. The optional `/compact` prompt triggers manual compaction.

### Claude Code features (filesystem config)

Off by default. Enable by setting `settingSources`:

| Source | Loads | Location |
| --- | --- | --- |
| `"project"` | CLAUDE.md, `.claude/rules/*.md`, project skills, project hooks, project `settings.json` | `<cwd>/.claude/` and parents |
| `"user"` | User CLAUDE.md, rules, skills, settings | `~/.claude/` |
| `"local"` | `CLAUDE.local.md`, `.claude/settings.local.json` | `<cwd>/` |

Full CLI parity: `["user", "project", "local"]`. Auto memory is CLI-only and never loads in the SDK.

Filesystem features available via `settingSources`:

- **Skills** — specialized capabilities in `.claude/skills/*/SKILL.md`.
- **Slash commands** — reusable prompts in `.claude/commands/*.md`. Can also be sent as input strings (e.g. `/compact`) to the SDK.
- **Memory / CLAUDE.md** — project context loaded on every request and prompt-cached.
- **Plugins** — bundled commands, agents, and MCP servers loaded via the programmatic `plugins` option.

### Streaming output vs single mode

| Mode | How | Use case |
| --- | --- | --- |
| Streaming (default) | `async for` over `query()` | Live UIs, progress updates |
| Single-turn / collect-all | Accumulate all messages, read final `ResultMessage` | CI jobs, batch processing |
| Partial messages | Set `includePartialMessages: true` → `StreamEvent` deltas | Token-by-token UIs |

### Structured outputs

Request typed JSON output with a schema (Pydantic model or JSON schema). On validation failure the SDK retries; exhausting retries yields `error_max_structured_output_retries`.

### Cost tracking and observability

`ResultMessage` provides `total_cost_usd`, `usage` (input tokens, output tokens, cache reads/creates), `num_turns`, and `session_id`. TypeScript emits additional observability events: hook events, tool progress, rate limits, and task notifications. Use these for metrics, dashboards, and audit trails. See the observability and cost-tracking references for full breakdowns.

### Todo tracking

The `TodoWrite` tool lets agents maintain a todo list that's visible in the message stream, useful for multi-step tasks and progress reporting.

### User input and approvals

- `canUseTool` callback: handle tool-use approval prompts at runtime (interactive UIs).
- `AskUserQuestion` tool: Claude asks the user multiple-choice clarifying questions. Also used during `plan` mode.
- In streaming mode, you can send additional user inputs mid-loop via `query.input()` / equivalent.

### Hosting and secure deployment

Deploy agents to Docker, serverless, or CI/CD. Security guidance covers: run agents with the least-privileged filesystem scope, prefer `dontAsk` or tight `allowedTools` in production, avoid `bypassPermissions` outside sandboxes (never as root on Unix), use deny rules to block dangerous bash patterns, and gate sensitive actions behind hooks or `canUseTool`.

### File checkpointing

The SDK records file-modification checkpoints that let you roll back edits made during a session. Useful for speculative refactors or letting users undo a run.

### Migration from the old Claude Code SDK

| Aspect | Old | New |
| --- | --- | --- |
| TypeScript package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Docs home | Claude Code docs | API Guide → Agent SDK section |

Uninstall the old package, install the new one, update imports. Options classes and function names are compatible (e.g. `ClaudeAgentOptions` replaces the old `ClaudeCodeOptions` in places — see migration guide for exact renames).

### TypeScript V2 preview

An unstable preview interface simplifies multi-turn conversations with `createSession()` / `resumeSession()` / `session.send()` / `session.stream()` and a `unstable_v2_prompt()` helper for one-shots. Session forking is V1-only for now.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities tour, Agent SDK vs Client SDK vs Claude Code CLI, branding, license.
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — build a bug-fixing agent end to end in Python or TypeScript.
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, message types, tool execution, context window, compaction, result handling.
- [Use Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — loading CLAUDE.md, skills, hooks, and settings via `settingSources`.
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — reading `usage`, `total_cost_usd`, cache metrics, per-turn accounting.
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — defining in-process tools with `@tool` / `tool()` and SDK MCP servers.
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — roll back file edits made during a session.
- [Control execution with hooks](references/claude-code-agent-sdk-hooks.md) — full hook event list, callback API, matchers, decisions.
- [Hosting](references/claude-code-agent-sdk-hosting.md) — deploying SDK agents to Docker, cloud, and CI/CD.
- [MCP](references/claude-code-agent-sdk-mcp.md) — connecting external MCP servers (stdio, SSE, HTTP, in-process) and tool search.
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — upgrading from `claude-code-sdk` / `@anthropic-ai/claude-code` to the Agent SDK.
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom system prompt, presets, appending to Claude Code preset.
- [Observability](references/claude-code-agent-sdk-observability.md) — monitoring, events, metrics, audit trails.
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, evaluation order, rule syntax.
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically in the SDK.
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full Python API: `query`, `ClaudeSDKClient`, `ClaudeAgentOptions`, message types.
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — security best practices, sandboxing, least privilege.
- [Session management](references/claude-code-agent-sdk-sessions.md) — resume, continue, fork patterns and session ids.
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — how Agent Skills load via `settingSources` and interact with the Skill tool.
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — sending slash commands as inputs and loading project commands.
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — partial messages, `StreamEvent`, live text and tool rendering.
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to stream, when to collect.
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON schema / Pydantic output typing with retries.
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, what subagents inherit, `parent_tool_use_id`.
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — the `TodoWrite` tool and progress tracking UX.
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — on-demand tool loading to save context.
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full V1 TypeScript API: `query`, `Options`, message types.
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable session-based V2 interface (`createSession`, `send`, `stream`).
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool`, `AskUserQuestion`, streaming user inputs mid-loop.

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Use Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
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
- Python: https://code.claude.com/docs/en/agent-sdk/python.md
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
- TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
