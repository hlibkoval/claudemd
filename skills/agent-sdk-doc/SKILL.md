---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — overview, quickstart, agent loop, TypeScript and Python API references, permissions, sessions, hooks, subagents, MCP, custom tools, structured outputs, streaming, observability, hosting, secure deployment, and migration guide.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly the Claude Code SDK), which lets you build production AI agents in Python and TypeScript.

## Quick Reference

### Installation

| Language | Package | Install |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

The TypeScript SDK bundles a native Claude Code binary — no separate Claude Code install needed.

### Authentication

| Provider | Environment Variable |
| :--- | :--- |
| Anthropic (direct) | `ANTHROPIC_API_KEY=your-api-key` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Basic Usage

```python
# Python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    async for message in query(
        prompt="Find and fix the bug in auth.py",
        options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
    ):
        print(message)

asyncio.run(main())
```

```typescript
// TypeScript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read files in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run shell commands, scripts, git operations |
| `Monitor` | Watch a background script and react to output lines |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `ToolSearch` | Load tools on-demand instead of preloading all |
| `Agent` | Spawn subagents for focused subtasks |
| `Skill` | Invoke project skills |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options |
| `TodoWrite` | Track tasks during a session |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Unmatched tools trigger `canUseTool` callback; no callback = deny | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and filesystem commands (`mkdir`, `touch`, `mv`, `cp`, `rm`, `sed`) | Trusted dev workflows |
| `plan` | Read-only tools run; Claude explores and produces a plan without modifying files | Review-before-edit |
| `dontAsk` | Anything not pre-approved is denied; `canUseTool` never called | Locked-down headless agents |
| `auto` (TS only) | Model classifier approves or denies each tool call | Autonomous agents with guardrails |
| `bypassPermissions` | All allowed tools run without prompts; deny rules still apply; cannot run as root | Sandboxed CI / fully trusted env |

**Permission evaluation order:** hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

### `ClaudeAgentOptions` Key Fields

| Option (Python / TypeScript) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | List of tools auto-approved (no prompting) |
| `disallowed_tools` / `disallowedTools` | Tools always blocked, even in `bypassPermissions` |
| `permission_mode` / `permissionMode` | Global permission mode (see table above) |
| `system_prompt` / `systemPrompt` | Custom system prompt or `{"type":"preset","preset":"claude_code"}` for full Claude Code prompt |
| `max_turns` / `maxTurns` | Max tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | Max spend before stopping |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Model ID (e.g. `"claude-sonnet-4-6"`); defaults to Claude Code default |
| `resume` | Session ID to resume a specific past session |
| `fork_session` / `forkSession` | `true` to fork from the resumed session (TypeScript also accepts `forkSession`) |
| `continue_conversation` / `continue` | Resume the most recent session in the current directory |
| `setting_sources` / `settingSources` | Which filesystem settings to load: `"user"`, `"project"`, `"local"` |
| `mcp_servers` / `mcpServers` | MCP server configs keyed by name |
| `hooks` | Hook callbacks keyed by event name |
| `agents` | Named subagent definitions |
| `include_partial_messages` / `includePartialMessages` | Enable streaming token-by-token output |
| `can_use_tool` / `canUseTool` | Callback for runtime approval of tool calls |
| `structured_output` / `structuredOutput` | JSON Schema, Zod (TS), or Pydantic (Python) for typed responses |

### Message Types

| Type | Python class | TS `type` field | When emitted |
| :--- | :--- | :--- | :--- |
| System | `SystemMessage` | `"system"` | Session start (`subtype: "init"`) and compaction boundary |
| Assistant | `AssistantMessage` | `"assistant"` | After each Claude response, including final text-only turn |
| User | `UserMessage` | `"user"` | After each tool execution with results |
| Stream event | `StreamEvent` | `"stream_event"` | Only when `includePartialMessages: true` |
| Result | `ResultMessage` | `"result"` | End of loop; always the last meaningful message |

### `ResultMessage` Subtypes

| Subtype | Meaning | `result` field? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancellation | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes include: `total_cost_usd`, `usage`, `num_turns`, `session_id`.

### Effort Levels

| Level | Behavior | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal reasoning | File lookups, listing directories |
| `"medium"` | Balanced reasoning | Routine edits, standard tasks |
| `"high"` | Thorough analysis (TypeScript default) | Refactors, debugging |
| `"xhigh"` | Extended reasoning depth | Coding/agentic tasks; recommended on Opus 4.7 |
| `"max"` | Maximum reasoning | Multi-step problems requiring deep analysis |

Python leaves `effort` unset by default (model's own default). TypeScript defaults to `"high"`.

### Session Management

| Goal | Python | TypeScript |
| :--- | :--- | :--- |
| Multi-turn in one process | `ClaudeSDKClient` (auto-tracks session) | `continue: true` on each subsequent `query()` |
| Resume most recent session | `continue_conversation=True` | `continue: true` |
| Resume a specific session | `resume=session_id` | `resume: sessionId` |
| Fork a session | `resume=session_id, fork_session=True` | `resume: sessionId, forkSession: true` |
| Stateless (no disk write) | Not supported (always persists) | `persistSession: false` |

Session files stored at: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`

### SDK Hooks (In-Process Callbacks)

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `PreToolUse` | Before a tool executes | Yes — return `permissionDecision: "deny"` |
| `PostToolUse` | After a tool returns | Side effects only |
| `UserPromptSubmit` | When a prompt is sent | Yes — return `decision: "block"` |
| `Stop` | When the agent finishes | Yes |
| `SubagentStart` / `SubagentStop` | When a subagent spawns or completes | `SubagentStop` can block |
| `PreCompact` | Before context compaction | Yes |
| `SessionStart` / `SessionEnd` | Session lifecycle | `SessionStart` only |

Hooks are configured via `options.hooks` as `{ EventName: [HookMatcher(matcher="...", hooks=[callback])] }`.

### MCP Server Configuration

```python
# Python
mcp_servers={
    "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},
    "docs": {"type": "http", "url": "https://code.claude.com/docs/mcp"}
}
```

Tool naming pattern: `mcp__<server>__<tool>` (e.g. `mcp__playwright__navigate`).  
Wildcard allow: `"mcp__myserver__*"`.

### Custom Tools (In-Process MCP Server)

```python
# Python: @tool decorator + create_sdk_mcp_server
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("my_tool", "Description", {"param": str})
async def my_tool(args): return {"content": [{"type": "text", "text": "result"}]}

server = create_sdk_mcp_server([my_tool])
options = ClaudeAgentOptions(mcp_servers={"custom": server})
```

```typescript
// TypeScript: tool() helper + createSdkMcpServer
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myTool = tool("my_tool", "Description", z.object({ param: z.string() }),
  async (args) => ({ content: [{ type: "text", text: "result" }] }));
const server = createSdkMcpServer([myTool]);
```

Set `readOnlyHint: true` on tool annotations to allow parallel execution.

### Subagent Definition

```python
# Python
from claude_agent_sdk import AgentDefinition
agents={
    "code-reviewer": AgentDefinition(
        description="When to invoke (Claude reads this).",
        prompt="System prompt for the subagent.",
        tools=["Read", "Glob", "Grep"],
    )
}
# Include "Agent" in allowedTools so Claude can invoke subagents
```

Each subagent starts with a fresh conversation (no parent history). Only the subagent's final response returns to the parent.

### System Prompt Options

| Method | How | When to use |
| :--- | :--- | :--- |
| CLAUDE.md | File at `.claude/CLAUDE.md` or `CLAUDE.md` + `settingSources: ["project"]` | Persistent project instructions |
| Append to preset | `{"type": "append", "text": "..."}` | Add rules without overriding Claude Code prompt |
| Full custom | `{"type": "custom", "text": "..."}` | Complete control (loses Claude Code guidelines) |
| Full preset | `{"type": "preset", "preset": "claude_code"}` | Full Claude Code prompt (tools, guidelines, style) |
| Default (minimal) | Omit `systemPrompt` | Just tool instructions, no coding guidelines |

### Structured Output

```python
# Python with Pydantic
from pydantic import BaseModel
class Result(BaseModel):
    name: str
    score: int

options = ClaudeAgentOptions(structured_output=Result)
```

```typescript
// TypeScript with Zod
import { z } from "zod";
const schema = z.object({ name: z.string(), score: z.number() });
const options = { structuredOutput: { schema } };
```

On mismatch, the SDK re-prompts up to the retry limit. Failure yields `error_max_structured_output_retries`.

### Observability (OpenTelemetry)

| Signal | Enable with |
| :--- | :--- |
| Metrics (tokens, cost, sessions) | `OTEL_METRICS_EXPORTER` |
| Log events (prompts, tool results) | `OTEL_LOGS_EXPORTER` |
| Traces (spans per tool/request, beta) | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` |

Pass via `options.env` for per-call config, or set in your process environment for all calls.

### Context Management Tips

- Content re-used across turns (system prompt, CLAUDE.md, tool definitions) is automatically **prompt-cached** (reduces cost).
- Use **subagents** for subtasks — their intermediate tool calls don't accumulate in the parent context.
- Use **`ToolSearch`** to load MCP tools on demand instead of preloading all schemas.
- Use lower `effort` for routine read-only tasks to reduce token usage.
- Manual compaction: send `"/compact"` as a prompt string mid-session.
- Add summarization instructions in `CLAUDE.md` to control what gets preserved during auto-compaction.

### Migration from Claude Code SDK

| | Old | New |
| :--- | :--- | :--- |
| TS package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Python import | `claude_code_sdk` | `claude_agent_sdk` |

### Hosting Requirements

- Python 3.10+ or Node.js 18+
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production (Modal, E2B, Fly, Cloudflare, Vercel, etc.)
- Cannot run `bypassPermissions` mode as root on Unix

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — what the Agent SDK is, capabilities (tools, hooks, subagents, MCP, permissions, sessions), comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to build a bug-fixing agent; key concepts for tools and permission modes
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — turns, message types, tool execution, context window, compaction, sessions, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full `query()`, `startup()`, `Options`, all message and type interfaces
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all classes and types
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, all permission modes with details
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; `ClaudeSDKClient` vs `continue: true`; cross-host session handling
- [Hooks](references/claude-code-agent-sdk-hooks.md) — all hook events, callback API, matchers, blocking/allowing tools, examples (audit logging, blocking dangerous ops)
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `@tool` / `tool()`, `createSdkMcpServer`, error handling, annotations, image/resource responses
- [Subagents](references/claude-code-agent-sdk-subagents.md) — programmatic and filesystem-based subagent definition, context isolation, parallelization
- [MCP](references/claude-code-agent-sdk-mcp.md) — stdio/HTTP/SSE transports, tool naming, authentication, tool search for large tool sets
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic; validation retries; error handling
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` handling, real-time text display
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to stream vs collect all messages; input streaming
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, permission approvals, `AskUserQuestion` clarifying prompts
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — CLAUDE.md, append, custom, and preset system prompt modes
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md/skills/hooks/commands from filesystem
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — reading `total_cost_usd` and `usage` from `ResultMessage`; token breakdown
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry traces, metrics, and log events; OTLP configuration
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container sandboxing, system requirements, sandbox providers, deployment patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert filesystem changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool for task tracking within sessions
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — on-demand MCP tool loading with `ToolSearch` to reduce context usage
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — using slash commands (including `/compact`) as prompts in the SDK
- [Skills](references/claude-code-agent-sdk-skills.md) — loading and invoking project skills in SDK agents
- [Plugins](references/claude-code-agent-sdk-plugins.md) — plugin integration with the Agent SDK
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — `createSession()` with `send()` / `stream()` patterns (unstable preview)
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from `@anthropic-ai/claude-code` / `claude-code-sdk` to the new package names

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
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
