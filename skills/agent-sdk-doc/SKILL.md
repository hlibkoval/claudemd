---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: building production AI agents in Python and TypeScript, with full coverage of the agent loop, sessions, permissions, hooks, subagents, MCP, custom tools, streaming, structured outputs, observability, and hosting.

## Quick Reference

### Installation

| Language | Package | Command |
|:---------|:--------|:--------|
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` (requires 3.10+) |

The TypeScript SDK bundles a native Claude Code binary — no separate Claude Code install needed.

**Migration note:** formerly `@anthropic-ai/claude-code` (TS) and `claude-code-sdk` (Python). Update imports accordingly.

### Core `query()` Pattern

```python
from claude_agent_sdk import query, ClaudeAgentOptions
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({ prompt: "...", options: { ... } })) { ... }
```

### Key `ClaudeAgentOptions` / `Options` Fields

| Field (Python / TypeScript) | Description |
|:---------------------------|:------------|
| `allowed_tools` / `allowedTools` | Pre-approve listed tools (no permission prompt) |
| `disallowed_tools` / `disallowedTools` | Remove tools from Claude's context entirely |
| `permission_mode` / `permissionMode` | Global tool permission behavior (see below) |
| `system_prompt` / `systemPrompt` | Custom system prompt or `claude_code` preset |
| `max_turns` / `maxTurns` | Cap on tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | Spend cap before stopping |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Model override (e.g., `"claude-sonnet-4-6"`) |
| `resume` | Session ID to resume |
| `fork_session` / `forkSession` | Fork a resumed session |
| `continue_conversation` / `continue` | Resume the most recent session in the cwd |
| `mcp_servers` / `mcpServers` | MCP server configs |
| `agents` | Subagent definitions (`AgentDefinition` map) |
| `hooks` | SDK hook callbacks |
| `cwd` | Working directory for the agent subprocess |
| `setting_sources` / `settingSources` | Which setting layers to load (`"project"`, `"user"`, `"local"`) |
| `include_partial_messages` / `includePartialMessages` | Enable real-time streaming output |
| `output_format` / `outputFormat` | Structured output schema |
| `can_use_tool` / `canUseTool` | Runtime tool approval callback |

### Built-in Tools

| Category | Tools | What they do |
|:---------|:------|:-------------|
| File operations | `Read`, `Edit`, `Write` | Read, modify, create files |
| Search | `Glob`, `Grep` | Find files by pattern, search content |
| Execution | `Bash` | Run shell commands, scripts, git |
| Web | `WebSearch`, `WebFetch` | Search and fetch web pages |
| Discovery | `ToolSearch` | Load MCP tools on demand |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate` | Subagents, skills, user prompts, tasks |
| Monitoring | `Monitor` | Watch background scripts line by line |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `"default"` | Unmatched tools trigger `canUseTool` callback; no callback = deny |
| `"acceptEdits"` | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, `mv`, `cp`, `sed`); other Bash follows default rules |
| `"plan"` | Read-only tools run; Claude explores and plans without editing files |
| `"dontAsk"` | Anything not pre-approved by allow rules is denied; `canUseTool` never called |
| `"auto"` (TS only) | Model classifier approves or denies each call |
| `"bypassPermissions"` | All allowed tools run without prompts; use only in isolated environments |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool`.

A bare-name deny rule like `Bash` removes the tool from Claude's context. A scoped rule like `Bash(rm *)` only blocks that pattern, in all modes including `bypassPermissions`.

### Message Types

| Type | Python class | TS type string | When it fires |
|:-----|:------------|:---------------|:--------------|
| Session init | `SystemMessage` (subtype `"init"`) | `"system"` / subtype `"init"` | First message; carries `session_id`, `mcp_servers` |
| Claude turn | `AssistantMessage` | `"assistant"` | After each Claude response; `.content` has text + tool calls |
| Tool results | `UserMessage` | `"user"` | After tool execution; sent back to Claude |
| Streaming | `StreamEvent` | `"stream_event"` | When `includePartialMessages` is enabled |
| Final result | `ResultMessage` | `"result"` | End of loop; has `subtype`, `result`, `total_cost_usd`, `session_id` |
| Compaction | `SystemMessage` (subtype `"compact_boundary"`) | `SDKCompactBoundaryMessage` | When context was compacted |

### Result Subtypes

| Subtype | Meaning | `result` field? |
|:--------|:--------|:----------------|
| `"success"` | Task completed normally | Yes |
| `"error_max_turns"` | Hit `maxTurns` limit | No |
| `"error_max_budget_usd"` | Hit `maxBudgetUsd` limit | No |
| `"error_during_execution"` | API failure or cancellation | No |
| `"error_max_structured_output_retries"` | Structured output validation failed | No |

All result subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Session Management

| Approach | Python | TypeScript | When to use |
|:---------|:-------|:-----------|:------------|
| One-shot | `query()` | `query()` | Single exchange |
| Multi-turn, same process | `ClaudeSDKClient` | `continue: true` | Ongoing conversation |
| Resume most recent | `continue_conversation=True` | `continue: true` | After process restart |
| Resume specific session | `resume=session_id` | `resume: sessionId` | Pick up a past session |
| Fork | `resume=id, fork_session=True` | `resume: id, forkSession: true` | Try alternative approach |
| Stateless (TS only) | — | `persistSession: false` | Ephemeral, no disk writes |

Session files live at `~/.claude/projects/<encoded-cwd>/*.jsonl`. Resume requires the same `cwd` and file to exist. Use a `SessionStore` adapter to persist across hosts.

### Hooks

| Hook Event | Python SDK | TS SDK | When it fires |
|:-----------|:---------:|:------:|:--------------|
| `PreToolUse` | Yes | Yes | Before a tool executes; can block or modify |
| `PostToolUse` | Yes | Yes | After a tool returns |
| `PostToolUseFailure` | Yes | Yes | On tool execution failure |
| `PostToolBatch` | No | Yes | After a full batch resolves |
| `UserPromptSubmit` | Yes | Yes | When a prompt is sent |
| `MessageDisplay` | No | Yes | When an assistant message text completes |
| `Stop` | Yes | Yes | When agent stops |
| `SubagentStart` | Yes | Yes | When a subagent spawns |
| `SubagentStop` | Yes | Yes | When a subagent completes |
| `PreCompact` | Yes | Yes | Before context compaction |
| `PermissionRequest` | Yes | Yes | When a permission dialog would show |
| `Notification` | Yes | Yes | Agent status messages |
| `SessionStart` | No | Yes | Session initialization |
| `SessionEnd` | No | Yes | Session termination |

Hook callbacks receive `(input_data, tool_use_id, context)`. Return `{}` to allow; return `hookSpecificOutput` with `permissionDecision: "deny"` to block. Deny beats defer, which beats ask, which beats allow.

Matcher syntax: pipe-separated exact names (`Write|Edit`) or regex (`^mcp__`). Omit matcher to match all events of that type.

### Subagents (`AgentDefinition`)

| Field | Required | Description |
|:------|:--------:|:------------|
| `description` | Yes | When Claude should delegate to this agent |
| `prompt` | Yes | System prompt for the subagent |
| `tools` | No | Allowed tool names; omit to inherit all |
| `disallowedTools` | No | Tools to remove |
| `model` | No | Model alias or full ID (`"sonnet"`, `"opus"`, etc.) |
| `effort` | No | Reasoning depth override |
| `maxTurns` | No | Turn cap for this subagent |
| `background` | No | Run as non-blocking background task |
| `skills` | No | Skills to preload into subagent context |
| `mcpServers` | No | MCP servers for this subagent |
| `permissionMode` | No | Permission mode override |

Include `Agent` in the parent's `allowedTools` to auto-approve subagent calls. Subagents cannot spawn their own subagents.

Subagent context: receives its own system prompt + Agent tool prompt + project CLAUDE.md + tool definitions. Does NOT receive parent conversation history or parent system prompt.

### MCP Servers

MCP tool naming: `mcp__<server-name>__<tool-name>`. Wildcard: `mcp__github__*`.

| Transport | Config key | Use for |
|:----------|:-----------|:--------|
| `stdio` | `command`, `args`, `env` | Local processes |
| `http` / `streamable-http` | `type: "http"`, `url`, `headers` | Remote HTTP servers (recommended) |
| `sse` | `type: "sse"`, `url`, `headers` | Remote SSE servers (deprecated) |
| SDK in-process | `createSdkMcpServer` / `create_sdk_mcp_server` | Custom in-process tools |

MCP tool search is enabled by default — defers tool schemas and loads on demand. Disabled automatically on Vertex AI / non-first-party `ANTHROPIC_BASE_URL` unless `ENABLE_TOOL_SEARCH=true`.

### Custom Tools

Define with `@tool` (Python) or `tool()` (TypeScript). Wrap in `create_sdk_mcp_server` / `createSdkMcpServer` and pass to `mcpServers`.

Handler must return `{ content: [{ type: "text"|"image"|"resource", ... }], isError?: boolean, structuredContent?: object }`.

Set `readOnlyHint: true` in tool annotations to enable parallel execution.

### Structured Outputs

Pass `output_format` (Python) / `outputFormat` (TypeScript) with a JSON Schema, Zod schema, or Pydantic model. The `result` message includes `structured_output` with validated data. If validation fails after retries, result subtype is `"error_max_structured_output_retries"`.

### System Prompts

| Use case | Setting |
|:---------|:--------|
| CLI-like coding tool, Claude Code defaults | `{ type: "preset", preset: "claude_code" }` |
| Same, plus product-specific rules | `claude_code` preset with `append` field |
| Custom agent, different surface/identity | Custom string |
| Thin tool loop, behavior in user prompt | No `systemPrompt` (minimal default) |

CLAUDE.md files load via `settingSources` and are injected as project context (not into the system prompt).

### Effort Levels

| Level | Good for |
|:------|:---------|
| `"low"` | File lookups, directory listing |
| `"medium"` | Routine edits, standard tasks |
| `"high"` | Refactors, debugging (TS default) |
| `"xhigh"` | Coding and agentic tasks; recommended on Opus 4.7 |
| `"max"` | Multi-step problems needing deep analysis |

Python default: unset (defers to model). TypeScript default: `"high"`.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` and choose exporters:

| Signal | Enable with | Contains |
|:-------|:-----------|:---------|
| Metrics | `OTEL_METRICS_EXPORTER` | Token/cost counters, session counts |
| Log events | `OTEL_LOGS_EXPORTER` | Per-prompt, API request/error, tool result records |
| Traces (beta) | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Spans per model call and tool |

Pass via `options.env` per-call or as process environment. In TypeScript, `env` replaces the inherited environment entirely — include `...process.env`.

### Cost Tracking

`total_cost_usd` on `ResultMessage` is a client-side estimate based on a bundled price table. Not authoritative for billing. For authoritative data use the Usage and Cost API or Claude Console. Per-step token usage is on each `AssistantMessage` (deduplicate by message ID when Claude calls multiple tools in one turn).

### Authentication Providers

| Provider | Environment variable |
|:---------|:---------------------|
| Anthropic API | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Hosting Patterns

| Pattern | Description | Best for |
|:--------|:------------|:---------|
| Ephemeral | One container per task, destroyed on completion | One-off tasks |
| Long-running | Persistent container, multiple concurrent sessions | Ongoing agents, chat bots |
| Hybrid | Mix of short and long sessions | General-purpose services |

Use `cwd` per `query()` call for session isolation. Session transcripts live at `~/.claude/projects/` by default; use `CLAUDE_CONFIG_DIR` to redirect. Use a `SessionStore` adapter for cross-host persistence.

### TypeScript-specific: `startup()` Pre-warming

`startup()` spawns the CLI subprocess and completes the initialize handshake before a prompt is available, eliminating first-call latency:

```typescript
const warm = await startup({ options });
for await (const msg of warm.query({ prompt: "..." })) { ... }
```

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — What the SDK is, capabilities summary, comparison with Client SDK / CLI / Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step: install, set API key, build a bug-fixing agent; permission modes quick table
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, tool execution, context window, compaction, session continuity, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — Full function signatures, types, and interfaces for TypeScript
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — Full function signatures, types, and classes for Python; `query()` vs `ClaudeSDKClient` comparison
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork patterns; `ClaudeSDKClient` vs `continue: true`; cross-host session strategies
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission evaluation order, allow/deny rules, all permission modes in detail
- [Hooks](references/claude-code-agent-sdk-hooks.md) — All hook events, matchers, callback API, async outputs, examples
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition` config, context isolation, parallelization, resuming subagents, tool restrictions
- [MCP](references/claude-code-agent-sdk-mcp.md) — Transport types, tool naming, allowedTools, tool search, authentication, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool` API, `createSdkMcpServer`, annotations, error handling, returning images
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — Enable `includePartialMessages`, handle `StreamEvent` for real-time text
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming input mode vs single-message input; when to use each
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema / Zod / Pydantic, `outputFormat` option, error handling
- [User input and approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, handling `AskUserQuestion`, interactive approval flows
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `claude_code` preset, `append`, custom strings, CLAUDE.md loading, output styles
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — Loading CLAUDE.md, skills, commands, and plugins via `settingSources`
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage fields, per-step vs cumulative, prompt caching, cost estimates
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry export: metrics, log events, traces; configuration via env vars
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns, container provisioning, multi-tenant isolation
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Security hardening, network controls, credential management, isolation options
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` adapter for cross-host session persistence
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and revert file changes the agent made within a session
- [Plugins (SDK)](references/claude-code-agent-sdk-plugins.md) — Using plugins programmatically in SDK agents
- [Skills (SDK)](references/claude-code-agent-sdk-skills.md) — Loading and using skills in SDK agents
- [Slash commands (SDK)](references/claude-code-agent-sdk-slash-commands.md) — Sending `/compact` and other commands as SDK inputs
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Configure on-demand MCP tool loading
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — Task tracking with `TaskCreate` / `TaskUpdate` tools
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — Migrating from `@anthropic-ai/claude-code` / `claude-code-sdk`
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — V2 session API history and removal note

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
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins (SDK): https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills (SDK): https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands (SDK): https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input and approvals: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
