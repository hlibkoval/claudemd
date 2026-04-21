---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents in Python and TypeScript with built-in tools, hooks, sessions, permissions, MCP, subagents, streaming, structured outputs, observability, and secure deployment.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

### Installation

| Language   | Package                            | Command                                        |
| :--------- | :--------------------------------- | :--------------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`   | `npm install @anthropic-ai/claude-agent-sdk`   |
| Python     | `claude-agent-sdk`                 | `pip install claude-agent-sdk`                 |

Set `ANTHROPIC_API_KEY` in your environment. Also supports Bedrock (`CLAUDE_CODE_USE_BEDROCK=1`), Vertex AI (`CLAUDE_CODE_USE_VERTEX=1`), and Azure (`CLAUDE_CODE_USE_FOUNDRY=1`).

### Core `query()` usage

```python
# Python
from claude_agent_sdk import query, ClaudeAgentOptions
async for message in query(prompt="...", options=ClaudeAgentOptions(...)):
    ...
```

```typescript
// TypeScript
import { query } from "@anthropic-ai/claude-agent-sdk";
for await (const message of query({ prompt: "...", options: { ... } })) { ... }
```

### ClaudeAgentOptions / Options — key fields

| Field (Python / TS)                              | Type                  | Description                                              |
| :----------------------------------------------- | :-------------------- | :------------------------------------------------------- |
| `allowed_tools` / `allowedTools`                 | `string[]`            | Auto-approve these tools (no prompt)                     |
| `disallowed_tools` / `disallowedTools`           | `string[]`            | Always deny these tools                                  |
| `permission_mode` / `permissionMode`             | see table below       | Global tool approval policy                              |
| `max_turns` / `maxTurns`                         | `int`                 | Cap tool-use round trips                                 |
| `max_budget_usd` / `maxBudgetUsd`                | `float`               | Stop when spend reaches this value                       |
| `effort`                                         | `"low"…"max"`         | Reasoning depth; TS default `"high"`, Python unset       |
| `model`                                          | `string`              | Model ID to use; defaults to Claude Code default         |
| `system_prompt` / `systemPrompt`                 | string or preset dict | Custom or preset (`"claude_code"`) system prompt         |
| `resume`                                         | `string`              | Resume a specific session by ID                          |
| `fork_session` / `forkSession`                   | `bool`                | Fork the resumed session (original unchanged)            |
| `continue_conversation` / `continue`             | `bool`                | Resume most-recent session in cwd                        |
| `setting_sources` / `settingSources`             | `string[]`            | Which filesystem sources to load (`"user"`, `"project"`) |
| `mcp_servers` / `mcpServers`                     | `dict`                | MCP server configs keyed by name                         |
| `hooks`                                          | `dict`                | SDK callback hooks by event name                         |
| `agents`                                         | `dict`                | Named subagent definitions                               |
| `plugins`                                        | `string[]`            | Local plugin directory paths                             |

### Permission modes

| Mode                 | Behavior                                                                        |
| :------------------- | :------------------------------------------------------------------------------ |
| `default`            | Unmatched tools call your `canUseTool` callback; no callback = deny             |
| `acceptEdits`        | Auto-approves file edits and common filesystem commands; other Bash follows rules |
| `dontAsk`            | Denies anything not pre-approved by allow rules; never calls `canUseTool`       |
| `plan`               | No tool execution; Claude plans only                                            |
| `bypassPermissions`  | All tools approved without prompts (use in isolated environments only)          |
| `auto` (TS only)     | Model classifier approves/denies each tool call                                 |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

### Built-in tools

| Category          | Tools                                              |
| :---------------- | :------------------------------------------------- |
| File operations   | `Read`, `Edit`, `Write`                            |
| Search            | `Glob`, `Grep`                                     |
| Execution         | `Bash`                                             |
| Web               | `WebSearch`, `WebFetch`                            |
| Discovery         | `ToolSearch`                                       |
| Orchestration     | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite`   |
| Monitoring        | `Monitor`                                          |

### Message types

| Type             | When emitted                                                  |
| :--------------- | :------------------------------------------------------------ |
| `SystemMessage`  | Session start (`subtype: "init"`) and compaction boundary     |
| `AssistantMessage` | After each Claude response (text + tool calls)              |
| `UserMessage`    | After each tool execution (tool results)                      |
| `StreamEvent`    | Only when `includePartialMessages: true` — raw API deltas     |
| `ResultMessage`  | End of loop; contains `result`, `session_id`, cost, usage     |

Check types: Python uses `isinstance(msg, ResultMessage)`; TypeScript uses `msg.type === "result"`.

### ResultMessage subtypes

| Subtype                              | Meaning                                 |
| :----------------------------------- | :-------------------------------------- |
| `success`                            | Task completed; `result` field present  |
| `error_max_turns`                    | Hit `maxTurns` limit                    |
| `error_max_budget_usd`               | Hit `maxBudgetUsd` limit                |
| `error_during_execution`             | API failure or cancelled request        |
| `error_max_structured_output_retries`| Structured output validation failed     |

### Sessions

| Pattern               | Python                                | TypeScript                         |
| :-------------------- | :------------------------------------ | :--------------------------------- |
| Auto multi-turn       | `ClaudeSDKClient` (context manager)   | `continue: true` on each call      |
| Resume specific       | `resume=session_id`                   | `resume: sessionId`                |
| Fork                  | `resume=id, fork_session=True`        | `resume: id, forkSession: true`    |
| Capture session ID    | From `ResultMessage.session_id`       | From `ResultMessage.session_id` or init `SystemMessage.session_id` |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `cwd` must match to resume.

### Hooks

| Hook Event           | Python | TS  | When it fires                             |
| :------------------- | :----: | :-: | :---------------------------------------- |
| `PreToolUse`         | Yes    | Yes | Before a tool executes (can block/modify) |
| `PostToolUse`        | Yes    | Yes | After a tool returns                      |
| `PostToolUseFailure` | Yes    | Yes | Tool execution failure                    |
| `UserPromptSubmit`   | Yes    | Yes | When a prompt is sent                     |
| `Stop`               | Yes    | Yes | Agent execution ends                      |
| `SubagentStart`      | Yes    | Yes | Subagent spawns                           |
| `SubagentStop`       | Yes    | Yes | Subagent completes                        |
| `PreCompact`         | Yes    | Yes | Before context compaction                 |
| `PermissionRequest`  | Yes    | Yes | Permission dialog would appear            |
| `Notification`       | Yes    | Yes | Agent status messages                     |
| `SessionStart`       | No     | Yes | Session initialization                    |
| `SessionEnd`         | No     | Yes | Session termination                       |

Hook callback returns `{}` to allow, or `{ hookSpecificOutput: { permissionDecision: "deny", ... } }` to block. Use `updatedInput` + `permissionDecision: "allow"` to redirect/transform inputs. Return `{ async_: True }` (Python) / `{ async: true }` (TS) for fire-and-forget side effects.

### Subagents (AgentDefinition fields)

| Field         | Type                                         | Description                                         |
| :------------ | :------------------------------------------- | :-------------------------------------------------- |
| `description` | `string` (required)                          | When Claude should use this agent                   |
| `prompt`      | `string` (required)                          | System prompt for the subagent                      |
| `tools`       | `string[]`                                   | Allowed tools; omit to inherit all                  |
| `model`       | `"sonnet" \| "opus" \| "haiku" \| "inherit"` | Model override; defaults to main model              |
| `skills`      | `string[]`                                   | Skill names available to this agent                 |
| `mcpServers`  | `(string \| object)[]`                       | MCP servers for this agent                          |

Include `"Agent"` in `allowedTools` to enable subagent invocation. Subagents cannot spawn their own subagents.

### MCP server config

```json
{
  "mcpServers": {
    "my-server": {
      "command": "npx",
      "args": ["-y", "@scope/server"],
      "env": { "API_KEY": "${API_KEY}" }
    },
    "remote": {
      "type": "http",
      "url": "https://api.example.com/mcp",
      "headers": { "Authorization": "Bearer ${TOKEN}" }
    }
  }
}
```

MCP tool naming: `mcp__<server-name>__<tool-name>`. Use wildcards in `allowedTools`: `"mcp__github__*"`. Tool search (enabled by default) withholds tool definitions until needed; requires Sonnet 4+ or Opus 4+.

### Effort levels

| Level    | Behavior                          | Good for                                     |
| :------- | :-------------------------------- | :------------------------------------------- |
| `"low"`  | Minimal reasoning, fast           | File lookups, listing directories            |
| `"medium"` | Balanced reasoning              | Routine edits, standard tasks                |
| `"high"` | Thorough analysis (TS default)    | Refactors, debugging                         |
| `"xhigh"` | Extended depth                  | Coding/agentic tasks; recommended on Opus 4.7 |
| `"max"`  | Maximum depth                     | Multi-step deep analysis                     |

### Structured outputs

Pass a JSON Schema (or Zod/Pydantic model) as `output_schema` / `outputSchema`. The SDK validates the final response and re-prompts on mismatch. On repeated failure the result is `error_max_structured_output_retries`.

### Context window management

| Strategy                        | How                                                                       |
| :------------------------------ | :------------------------------------------------------------------------ |
| Automatic compaction            | SDK summarizes history when context fills; emits `compact_boundary` event |
| Manual compaction               | Send `/compact` as the prompt string                                      |
| `PreCompact` hook               | Archive transcript before compaction                                      |
| Subagents for subtasks          | Keeps parent context lean; only final result returns                      |
| Tool search                     | Loads tool definitions on demand instead of preloading all                |
| `settingSources: []`            | Disable all filesystem settings loading                                   |

### System prompt customization

| Method                             | Usage                                                         |
| :--------------------------------- | :------------------------------------------------------------ |
| Default (minimal)                  | No `systemPrompt` set; tool instructions only                 |
| Claude Code preset                 | `{ "type": "preset", "preset": "claude_code" }`               |
| Append to preset                   | `{ "type": "append", "content": "..." }`                      |
| Fully custom                       | Pass a plain string to `systemPrompt`                         |
| `CLAUDE.md` files                  | Loaded via `settingSources`; re-injected every request        |

### Observability (OpenTelemetry)

Configure via environment variables (inherited by the CLI child process):

| Signal   | Enable var             | Endpoint var              |
| :------- | :--------------------- | :------------------------ |
| Traces   | `OTEL_TRACES_ENABLE=1` | `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` |
| Metrics  | `OTEL_METRICS_ENABLE=1`| `OTEL_EXPORTER_OTLP_METRICS_ENDPOINT` |
| Logs     | `OTEL_LOGS_ENABLE=1`   | `OTEL_EXPORTER_OTLP_LOGS_ENDPOINT` |

### Migration from Claude Code SDK

| Aspect              | Old                         | New                              |
| :------------------ | :-------------------------- | :------------------------------- |
| TS/JS package       | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package      | `claude-code-sdk`           | `claude-agent-sdk`               |
| Import (Python)     | `from claude_code_sdk import ...` | `from claude_agent_sdk import ...` |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities summary, comparison to Client SDK and CLI, get-started steps
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step guide to building a bug-fixing agent, key concepts for tools and permission modes
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — loop lifecycle, message types, tool execution, turns, budget/effort controls, context window, sessions, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full TypeScript API: `query()`, `Options`, message types, hook types, tool types, `ClaudeSDKClient` equivalent patterns
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full Python API: `query()`, `ClaudeAgentOptions`, `ClaudeSDKClient`, message types, hook types, tool types
- [TypeScript SDK V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — unstable preview with `createSession()`, `send()`, `stream()` pattern
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — hook configuration, matchers, callback inputs/outputs, async outputs, examples (block tools, modify inputs, chain hooks, Slack notifications)
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, permission modes, dynamic mode changes, mode details
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, surfacing permission prompts and `AskUserQuestion` to users
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; session IDs; cross-host resumption; session listing/tagging
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — transport types (stdio/HTTP/SSE/SDK), tool naming, `allowedTools`, authentication, tool search, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — in-process MCP server, `@tool` / `tool()` decorator, annotations, error handling, image/resource returns
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — on-demand tool loading, configuration, optimization for large tool sets
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, programmatic vs filesystem definitions, what subagents inherit, invocation, resuming subagents, tool restrictions
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` handling, text delta extraction
- [Streaming Input](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — streaming input mode vs single-message mode, when to use each
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic integration, retry behavior, error handling
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — token usage fields, per-model cost, deduplicating parallel tool calls, cost estimation caveats
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — tracking/restoring file changes made by Write/Edit/NotebookEdit tools
- [Work with sessions (continued)](references/claude-code-agent-sdk-sessions.md) — see sessions reference above
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md, skills, hooks, agents from filesystem
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — CLAUDE.md approach, append to preset, fully custom prompt
- [Agent Skills in the SDK](references/claude-code-agent-sdk-skills.md) — loading skills via `settingSources`, enabling via `allowedTools: ["Skill"]`
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — discovering and sending `/compact`, `/context`, custom commands
- [Todo Lists](references/claude-code-agent-sdk-todo-tracking.md) — built-in todo lifecycle and when todos are created automatically
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — loading local plugins via `plugins` option; skills, agents, hooks, MCP servers
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — container-based sandboxing, system requirements, production deployment patterns
- [Securely deploying AI agents](references/claude-code-agent-sdk-secure-deployment.md) — threat model, built-in security features, prompt injection mitigations, network controls
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — traces/metrics/logs export, OTLP env vars, tagging and filtering
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — package rename from `claude-code-sdk` / `@anthropic-ai/claude-code`, migration steps

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- TypeScript SDK V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming Input: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Agent Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Todo Lists: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Securely deploying AI agents: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
