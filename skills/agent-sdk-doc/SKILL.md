---
name: agent-sdk-doc
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly the Claude Code SDK) — a Python and TypeScript library for building production AI agents that autonomously read files, run commands, search the web, edit code, and more.

## Quick Reference

### Installation

| Language   | Package                              | Command                                    |
| ---------- | ------------------------------------ | ------------------------------------------ |
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`             |

The TypeScript SDK bundles a native Claude Code binary — no separate install needed.

### Authentication

```bash
export ANTHROPIC_API_KEY=your-api-key
# Third-party providers:
# CLAUDE_CODE_USE_BEDROCK=1   (Amazon Bedrock)
# CLAUDE_CODE_USE_VERTEX=1    (Google Vertex AI)
# CLAUDE_CODE_USE_FOUNDRY=1   (Microsoft Azure)
```

### Core Entry Points

| Language   | One-shot / new session        | Multi-turn / persistent session                          |
| ---------- | ----------------------------- | -------------------------------------------------------- |
| TypeScript | `query({ prompt, options })`  | `query(..., { continue: true })` or V2 `createSession()` |
| Python     | `query(prompt=..., options=…)` | `ClaudeSDKClient` (async context manager)                |

### Built-in Tools

| Tool            | What it does                                             |
| --------------- | -------------------------------------------------------- |
| `Read`          | Read any file in the working directory                   |
| `Write`         | Create new files                                         |
| `Edit`          | Make precise edits to existing files                     |
| `Bash`          | Run terminal commands, scripts, git operations           |
| `Monitor`       | Watch a background script; react to each output line     |
| `Glob`          | Find files by pattern (`**/*.ts`, `src/**/*.py`)         |
| `Grep`          | Search file contents with regex                          |
| `WebSearch`     | Search the web for current information                   |
| `WebFetch`      | Fetch and parse web page content                         |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice |
| `Agent`         | Invoke a subagent (required in `allowedTools` to use subagents) |

### Permission Modes

| Mode                | Behavior                                                                 | Best for                          |
| ------------------- | ------------------------------------------------------------------------ | --------------------------------- |
| `default`           | No auto-approvals; unmatched tools call `canUseTool` callback            | Custom approval flows             |
| `acceptEdits`       | Auto-approves file edits and filesystem commands (`mkdir`, `rm`, etc.)   | Trusted dev workflows             |
| `dontAsk`           | Denies anything not in `allowedTools`; never calls `canUseTool`          | Locked-down headless agents       |
| `bypassPermissions` | All tools run without prompts (use with caution)                         | Sandboxed CI / fully trusted envs |
| `plan`              | No tool execution; Claude plans without making changes                   | Code review / proposal workflows  |
| `auto` (TS only)    | A model classifier approves or denies each tool call                     | Autonomous agents with guardrails |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

`disallowed_tools` deny rules hold even in `bypassPermissions` mode. `allowed_tools` does not constrain `bypassPermissions`.

### Session Options (key fields on `ClaudeAgentOptions` / `Options`)

| Python field              | TypeScript field        | Description                                         |
| ------------------------- | ----------------------- | --------------------------------------------------- |
| `allowed_tools`           | `allowedTools`          | Pre-approved tools (auto-approved, not exclusively available) |
| `disallowed_tools`        | `disallowedTools`       | Always-denied tools                                 |
| `permission_mode`         | `permissionMode`        | One of the modes above                              |
| `system_prompt`           | `systemPrompt`          | Custom system prompt                                |
| `max_turns`               | `maxTurns`              | Cap tool-call turns                                 |
| `max_budget_usd`          | `maxBudgetUsd`          | Stop when estimated spend reaches threshold         |
| `mcp_servers`             | `mcpServers`            | External MCP servers dict                           |
| `resume`                  | `resume`                | Session ID to resume                                |
| `fork_session`            | `forkSession`           | Fork the resumed session                            |
| `continue_conversation`   | `continue`              | Resume the most-recent session in the cwd           |
| `cwd`                     | `cwd`                   | Working directory for the agent                     |
| `setting_sources`         | `settingSources`        | Which config sources to load (`"project"`, `"user"`, etc.) |
| `agents`                  | `agents`                | Dict of named `AgentDefinition` / agent objects     |
| `hooks`                   | `hooks`                 | SDK hook callbacks keyed by event type              |
| `persist_session`         | `persistSession`        | Write session to disk (TypeScript; Python always persists) |

### Message Types (streaming output)

| Type              | When emitted                                   | Key fields                              |
| ----------------- | ---------------------------------------------- | --------------------------------------- |
| `SystemMessage`   | Session start (`init`) and compaction boundary | `session_id` (TS: direct; Py: in `.data`) |
| `AssistantMessage`| After each Claude response / tool-call turn    | `.content` (text + tool call blocks)    |
| `UserMessage`     | After each tool result fed back to Claude      | `.content` (tool results)               |
| `StreamEvent`     | Only with partial messages enabled             | Raw API streaming events                |
| `ResultMessage`   | End of agent loop                              | `.subtype`, `.result`, `.total_cost_usd`, `.session_id` |

Result subtypes: `success`, `error_max_turns`, `error_max_budget_usd`, `error`.

**Python**: check with `isinstance(msg, ResultMessage)`. **TypeScript**: check `msg.type === "result"`.

### Hooks

Register callbacks in `options.hooks` keyed by event name:

| Event name          | When it fires                         |
| ------------------- | ------------------------------------- |
| `PreToolUse`        | Before a tool executes                |
| `PostToolUse`       | After a tool returns                  |
| `Stop`              | When the agent loop ends              |
| `SessionStart`      | When a session begins                 |
| `SessionEnd`        | When a session ends                   |
| `UserPromptSubmit`  | When a user prompt is submitted       |

Each hook entry is a `HookMatcher` with a `matcher` regex string and a list of async callback functions. Return `{}` to allow, or `{"hookSpecificOutput": {"permissionDecision": "deny", ...}}` to block.

### Sessions

| Operation     | Python option            | TypeScript option    | Effect                                          |
| ------------- | ------------------------ | -------------------- | ----------------------------------------------- |
| New session   | (default)                | (default)            | Fresh conversation                              |
| Continue      | `continue_conversation=True` | `continue: true` | Resume most-recent session in cwd               |
| Resume by ID  | `resume=session_id`      | `resume: sessionId`  | Resume a specific session                       |
| Fork          | `resume=id, fork_session=True` | `resume: id, forkSession: true` | New session branching from existing history |

Session files: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `cwd` must match when resuming.

### Custom Tools (in-process MCP server)

**Python** — `@tool` decorator + `create_sdk_mcp_server`:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool(name="get_temp", description="Get temperature", input_schema={"city": str})
async def get_temp(city: str) -> dict:
    return {"content": [{"type": "text", "text": f"72°F in {city}"}]}

server = create_sdk_mcp_server([get_temp])
options = ClaudeAgentOptions(mcp_servers={"weather": server})
```

**TypeScript** — `tool()` helper (Zod schema) + `createSdkMcpServer`:
```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const getTemp = tool("get_temp", "Get temperature", { city: z.string() },
  async ({ city }) => ({ content: [{ type: "text", text: `72°F in ${city}` }] }));

const server = createSdkMcpServer([getTemp]);
```

### Subagents

Include `"Agent"` in `allowedTools`. Define agents via the `agents` option:
```python
agents={"reviewer": AgentDefinition(
    description="Expert code reviewer",
    prompt="Analyze code quality",
    tools=["Read", "Glob", "Grep"]
)}
```
Each subagent runs in a fresh context. Only its final message returns to the parent. Messages from within a subagent carry a `parent_tool_use_id` field.

### Structured Outputs

Pass an `output_schema` (Python) or `outputSchema` (TypeScript) to `query()`. The SDK validates Claude's response against the schema and re-prompts on mismatch. Use Pydantic (Python) or Zod (TypeScript) for type-safe schemas.

### Cost Tracking

`ResultMessage` exposes `.total_cost_usd` (Python) / `.costUSD` (TypeScript) as **client-side estimates** only. Use the Usage and Cost API or Claude Console for authoritative billing. Per-turn usage is available on each `AssistantMessage`.

### Observability (OpenTelemetry)

Configure via environment variables (process env or `options.env`). The CLI child process exports OTLP traces, metrics, and logs. Supported backends: Honeycomb, Datadog, Grafana, Langfuse, and any OTLP-compatible collector.

### File Checkpointing

Tracks changes made through Write, Edit, and NotebookEdit tools. Allows rewinding files to any checkpoint. Changes made via Bash commands are not tracked.

### Hosting Requirements

- Python 3.10+ or Node.js 18+; SDKs bundle the Claude Code binary
- Recommended: 1 GiB RAM, 5 GiB disk, 1 CPU per instance
- Outbound HTTPS to `api.anthropic.com`
- Run inside a sandboxed container for production

### Migration from Claude Code SDK

| Aspect          | Old                          | New                              |
| --------------- | ---------------------------- | -------------------------------- |
| TS/JS package   | `@anthropic-ai/claude-code`  | `@anthropic-ai/claude-agent-sdk` |
| Python package  | `claude-code-sdk`            | `claude-agent-sdk`               |
| Python import   | `from claude_code_sdk import` | `from claude_agent_sdk import`  |

All API signatures are backward-compatible; only package/import names changed.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — Introduction, capabilities, built-in tools table, and comparison to the Anthropic Client SDK
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes; covers setup, tools, and permission modes
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Turn lifecycle, message types, context window, compaction, and budget limits
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — Complete API reference: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — Complete API reference: `query()`, `startup()`, `tool()`, `Options`, all message types
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Simplified `send()` / `stream()` patterns (unstable preview)
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; `ClaudeSDKClient` (Python) and `continue: true` (TypeScript); cross-host resume
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, `allowedTools`, dynamic `setPermissionMode()`
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive approval flows
- [Intercept and control behavior with hooks](references/claude-code-agent-sdk-hooks.md) — Hook events, matchers, callback return values, blocking/modifying tool calls
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — Defining subagents, context isolation, parallelization, `AgentDefinition`
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — MCP transport types (stdio, HTTP/SSE), tool search for large tool sets, auth
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP server, `@tool` / `tool()`, error handling, returning images
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Load tools on demand for large MCP tool sets
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, validation and retry behavior
- [Streaming input modes](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming input (recommended) vs single-message mode; image uploads, interrupts
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` handling
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — Token usage fields, deduplication for parallel tool calls, cost estimates vs billing
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — OTLP traces, metrics, log events, environment variable configuration
- [Rewind file changes with checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Track and restore file changes; Write/Edit tracked; Bash not tracked
- [Work with sessions (storage)](references/claude-code-agent-sdk-sessions.md) — Session file location, `listSessions()`, `getSessionMessages()`, session tags
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — Agent task tracking within sessions
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom system prompts, CLAUDE.md memory files
- [Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — Skills, slash commands, plugins, memory (CLAUDE.md) via `settingSources`
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — Loading `.claude/skills/*/SKILL.md` files into agent context
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — Using `.claude/commands/*.md` custom commands in SDK agents
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — Loading Claude Code plugins programmatically via the `plugins` option
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — Production deployment, container sandboxing, system requirements, sandbox providers
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Network controls, credential management, isolation hardening
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — Package rename steps for TypeScript and Python

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Rewind file changes with checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Intercept and control behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming input modes: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
