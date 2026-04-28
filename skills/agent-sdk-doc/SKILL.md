---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the programmatic interface for building production AI agents with Claude Code's tools, agent loop, and context management.

## Quick Reference

### Installation

| SDK | Package | Install |
| --- | ------- | ------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

Bundles a native Claude Code binary — no separate Claude Code install needed.

### Authentication

| Provider | Environment variable |
| -------- | -------------------- |
| Anthropic (direct) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Core Function: `query()`

The primary entry point. Returns an async iterator that streams messages as the agent works.

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

### Key Options (ClaudeAgentOptions / Options)

| Python field | TypeScript field | Description |
| ------------ | ---------------- | ----------- |
| `allowed_tools` | `allowedTools` | Auto-approve these tools (no permission prompt) |
| `disallowed_tools` | `disallowedTools` | Always deny these tools |
| `permission_mode` | `permissionMode` | Global permission behavior (see table below) |
| `system_prompt` | `systemPrompt` | Override or append to the system prompt |
| `max_turns` | `maxTurns` | Cap tool-use turns (prevents runaway agents) |
| `max_budget_usd` | `maxBudgetUsd` | Stop when cost exceeds this threshold |
| `effort` | `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | `model` | Pin a specific model ID |
| `mcp_servers` | `mcpServers` | Connect external MCP servers |
| `hooks` | `hooks` | Callback hooks for agent lifecycle events |
| `agents` | `agents` | Define subagent specialists |
| `resume` | `resume` | Resume a prior session by ID |
| `fork_session` | `forkSession` | Fork a session to branch history |
| `continue_conversation` | `continue` | Resume the most recent session in `cwd` |
| `setting_sources` | `settingSources` | Control which filesystem settings load (user, project, local) |
| `cwd` | `cwd` | Working directory for the agent |
| `output_format` | `outputFormat` | Schema for structured output |
| `include_partial_messages` | `includePartialMessages` | Enable real-time streaming of text deltas |
| `can_use_tool` | `canUseTool` | Callback for interactive tool approval |
| `plugins` | `plugins` | Load Claude Code plugins from local paths |

### Permission Modes

| Mode | Behavior | Best for |
| ---- | -------- | -------- |
| `"default"` | Tools not in allow rules call `canUseTool`; no callback = deny | Custom approval flows |
| `"acceptEdits"` | Auto-approves file edits + common filesystem commands (`mkdir`, `touch`, `mv`, `cp`) | Trusted dev workflows |
| `"plan"` | No tool execution; Claude produces a plan | Review before acting |
| `"dontAsk"` | Only `allowedTools` run; everything else is denied (no prompting) | Locked-down headless agents |
| `"auto"` (TypeScript only) | Model classifier approves/denies each call | Autonomous agents with safety guardrails |
| `"bypassPermissions"` | All allowed tools run without prompts (cannot be used as root) | Isolated CI/container environments |

Permission evaluation order: **Hooks → Deny rules → Permission mode → Allow rules → canUseTool callback**

### Built-in Tools

| Category | Tools |
| -------- | ----- |
| File operations | `Read`, `Write`, `Edit` |
| Search | `Glob`, `Grep` |
| Execution | `Bash` |
| Web | `WebSearch`, `WebFetch` |
| Discovery | `ToolSearch` |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite`, `Monitor` |

Tool name syntax for scoped allow/deny: `"Bash(npm *)"` (allows only npm commands via Bash).
MCP tool syntax: `"mcp__<server-name>__<tool-name>"` or `"mcp__<server-name>__*"` for all tools from a server.

### Message Types

| Type | Python class | TypeScript `type` field | When emitted |
| ---- | ------------ | ----------------------- | ------------ |
| System init | `SystemMessage` (subtype `"init"`) | `"system"` / subtype `"init"` | Start of session; contains `session_id`, `slash_commands` |
| Assistant turn | `AssistantMessage` | `"assistant"` | After each Claude response (text + tool calls) |
| Tool result | `UserMessage` | `"user"` | After each tool execution |
| Streaming delta | `StreamEvent` | `"stream_event"` | When `includePartialMessages` is enabled |
| Final result | `ResultMessage` | `"result"` | End of agent loop; contains cost, usage, `session_id` |
| Compact boundary | `SystemMessage` (subtype `"compact_boundary"`) | `SDKCompactBoundaryMessage` | After automatic context compaction |

**Python:** use `isinstance(message, ResultMessage)` to check type.  
**TypeScript:** use `message.type === "result"`. Content blocks are at `message.message.content`, not `message.content`.

### Result Subtypes

| Subtype | Meaning | `result` field? |
| ------- | ------- | --------------- |
| `"success"` | Task completed normally | Yes |
| `"error_max_turns"` | Hit `maxTurns` limit | No |
| `"error_max_budget_usd"` | Hit `maxBudgetUsd` limit | No |
| `"error_during_execution"` | API failure or cancellation | No |
| `"error_max_structured_output_retries"` | Structured output validation failed | No |

All result subtypes include `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Sessions

| Goal | Python | TypeScript |
| ---- | ------ | ---------- |
| Maintain multi-turn conversation | `ClaudeSDKClient` | `continue: true` |
| Resume most-recent session | `continue_conversation=True` | `continue: true` |
| Resume specific session | `resume=session_id` | `resume: sessionId` |
| Fork to explore alternative | `resume=session_id, fork_session=True` | `resume: sessionId, forkSession: true` |
| Stateless (no disk persistence) | Not available | `persistSession: false` |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `cwd` must match on resume.

### Hooks

Register callbacks in `options.hooks` (Python) / `options.hooks` (TypeScript).

| Hook | Fires when | Common uses |
| ---- | ---------- | ----------- |
| `PreToolUse` | Before a tool executes | Block dangerous commands, validate inputs |
| `PostToolUse` | After a tool returns | Audit outputs, trigger side effects |
| `UserPromptSubmit` | When a prompt is sent | Inject additional context |
| `Stop` | When the agent finishes | Validate result, save session state |
| `SubagentStart` / `SubagentStop` | Subagent spawns or completes | Track parallel task results |
| `PreCompact` | Before context compaction | Archive full transcript |
| `SessionStart` / `SessionEnd` | Session lifecycle | Resource management |

**Python pattern:**
```python
ClaudeAgentOptions(hooks={
    "PreToolUse": [HookMatcher(matcher="Edit|Write", hooks=[my_callback])]
})
```

Hook callbacks return `{}` to allow, or `{"hookSpecificOutput": {"permissionDecision": "deny", ...}}` to block.

### Custom Tools (In-process MCP Server)

Define tools with `@tool` (Python) or `tool()` (TypeScript), then register via `create_sdk_mcp_server` / `createSdkMcpServer`, and pass to `mcpServers` in query options.

Handler must return `{"content": [{"type": "text", "text": "..."}]}`. Set `"isError": true` to signal failure without stopping the loop.

Mark tools `readOnlyHint: true` (Python) / `readOnlyHint: true` in annotations (TypeScript) to enable parallel execution.

### Subagents

Include `"Agent"` in `allowedTools`. Define via `agents` option:

```python
AgentDefinition(
    description="When to invoke this agent",
    prompt="Specialized system prompt",
    tools=["Read", "Glob"]  # scope tools for this subagent
)
```

Each subagent runs in a fresh conversation — only its final response returns to the parent. Use for context isolation, parallelization, or specialized instructions.

### Structured Outputs

Pass `output_format` (Python) / `outputFormat` (TypeScript) with a JSON Schema (or Zod/Pydantic schema). The result message includes a `structured_output` field with validated data. Use Pydantic (Python) or Zod (TypeScript) for type-safe schemas.

### MCP Servers

Configure in `mcp_servers` / `mcpServers` option. Three transport types:

| Type | Config example |
| ---- | -------------- |
| stdio (local process) | `{"command": "npx", "args": ["@playwright/mcp@latest"]}` |
| HTTP/SSE | `{"type": "http", "url": "https://example.com/mcp"}` |
| In-process (SDK server) | Result of `createSdkMcpServer(...)` |

Use `ToolSearch` tool to load MCP tools on demand instead of preloading all — helps with context efficiency when using large MCP tool sets.

### System Prompt Customization

| Method | How |
| ------ | --- |
| Full Claude Code preset | `systemPrompt: {type: "preset", preset: "claude_code"}` |
| Append to preset | `systemPrompt: {type: "preset", preset: "claude_code", appendSystemPrompt: "..."}` |
| Fully custom | `systemPrompt: "Your custom prompt"` |
| Project instructions | `CLAUDE.md` or `.claude/CLAUDE.md` loaded via `settingSources` |

Default SDK system prompt is minimal — omits Claude Code's coding guidelines. Specify the preset explicitly to include them.

### Effort Levels

| Level | Best for |
| ----- | -------- |
| `"low"` | File lookups, directory listings |
| `"medium"` | Routine edits, standard tasks |
| `"high"` | Refactors, debugging (TypeScript default) |
| `"xhigh"` | Coding and agentic tasks; recommended on Opus 4.7 |
| `"max"` | Multi-step problems requiring deep analysis |

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus signal-specific env vars:

| Signal | Enable var | Notes |
| ------ | ---------- | ----- |
| Metrics | `OTEL_METRICS_EXPORTER=otlp` | Counters for tokens, cost, sessions |
| Log events | `OTEL_LOGS_EXPORTER=otlp` | Per-prompt, per-tool-call structured records |
| Traces | `OTEL_TRACES_EXPORTER=otlp` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Spans for model requests and tool calls (beta) |

Configure via process env or `options.env`. In TypeScript, `env` replaces inherited env — include `...process.env`.

### Migration from Claude Code SDK

| Aspect | Old | New |
| ------ | --- | --- |
| TypeScript package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| ------- | --------- | ----------------- |
| Session | New each time | Reuses same session |
| Multi-turn | No (use resume) | Yes (automatic) |
| Interrupts | No | Yes |
| Use case | One-off tasks | Continuous conversations |

### Hosting Requirements

- Python 3.10+ or Node.js 18+
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production

### File Checkpointing

Enable to track Write/Edit/NotebookEdit changes and restore files to prior states. Checkpoint UUIDs appear on `UserMessage` objects in the stream. Bash-driven file changes are **not** tracked.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK Overview](references/claude-code-agent-sdk-overview.md) — Introduction, capabilities, and comparison with other Claude tools
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes; permission mode reference
- [How the Agent Loop Works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, context window, compaction, result handling
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete TypeScript API: `query()`, `startup()`, `tool()`, `createSdkMcpServer()`, all types
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete Python API: `query()`, `ClaudeSDKClient`, `@tool`, `create_sdk_mcp_server()`, all types
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork patterns; cross-host session handling
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Allow/deny rules, permission modes, evaluation order
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Lifecycle callbacks, matchers, outputs, blocking tool calls
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Programmatic subagent definition, context isolation, parallelization
- [MCP Integration](references/claude-code-agent-sdk-mcp.md) — Stdio, HTTP/SSE, in-process servers; tool search for large tool sets
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP server, schemas, handlers, annotations, error handling
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic; validated output after multi-turn tool use
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Enable `includePartialMessages` for real-time text deltas
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Input modes: persistent streaming vs one-shot queries
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — CLAUDE.md, presets, append, and fully custom system prompts
- [Claude Code Features in SDK](references/claude-code-agent-sdk-claude-code-features.md) — settingSources, skills, hooks, CLAUDE.md loading
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — Filesystem-based Agent Skills; enabling with `"Skill"` in allowedTools
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — Sending `/compact`, `/context`, etc. through the SDK
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — Load local plugin directories with skills, agents, hooks, and MCP servers
- [User Input and Approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback; surfacing tool approval and AskUserQuestion to users
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage, `total_cost_usd`, per-step vs cumulative, prompt caching
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, and log events via OTLP
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Dynamic on-demand tool loading for large tool sets
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — Built-in `TodoWrite` tool; lifecycle for complex multi-step tasks
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Track and rewind file changes; checkpoint UUIDs in the message stream
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Container sandboxing, system requirements, production deployment patterns
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Threat model, isolation, least privilege, credential management, network controls
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Migrating from `@anthropic-ai/claude-code` / `claude-code-sdk` to new package names
- [TypeScript V2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Unstable `send()` / `stream()` interface preview; `createSession()` pattern

## Sources

- Agent SDK Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- Agent Loop: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code Features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
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
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK Reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure Deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming Output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs Single Mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured Outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool Search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
