---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK (formerly Claude Code SDK) — build production AI agents with Claude Code as a library in Python and TypeScript, with built-in tools, hooks, subagents, MCP, permissions, sessions, structured outputs, and hosting.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### Installation

| Language   | Package                              | Install command                          |
| :--------- | :----------------------------------- | :--------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`           |

The TypeScript SDK bundles a native Claude Code binary; no separate install needed. Set `ANTHROPIC_API_KEY` or configure Bedrock/Vertex/Foundry.

### Core API

| Interface              | Python                    | TypeScript                   | Use case                          |
| :--------------------- | :------------------------ | :--------------------------- | :-------------------------------- |
| One-shot query         | `query(prompt, options)`  | `query({prompt, options})`   | Single tasks, no follow-up        |
| Multi-turn client      | `ClaudeSDKClient`         | `continue: true` in options  | Conversations with context        |
| Pre-warm subprocess    | N/A                       | `startup()` then `.query()`  | Reduce first-query latency        |

Both return async iterators yielding messages as the agent works.

### Message types

| Type              | When emitted                                | Key fields                              |
| :---------------- | :------------------------------------------ | :-------------------------------------- |
| `SystemMessage`   | Session init, compaction                     | `subtype` (`init`, `compact_boundary`)  |
| `AssistantMessage` | After each Claude response                  | `content` (text + tool call blocks)     |
| `UserMessage`     | After tool execution                         | Tool result content                     |
| `StreamEvent`     | When `includePartialMessages` enabled        | Raw API streaming events                |
| `ResultMessage`   | End of agent loop                            | `result`, `subtype`, `total_cost_usd`, `session_id` |

### Built-in tools

| Tool            | What it does                                     |
| :-------------- | :----------------------------------------------- |
| `Read`          | Read any file in the working directory            |
| `Write`         | Create new files                                  |
| `Edit`          | Make precise edits to existing files              |
| `Bash`          | Run terminal commands, scripts, git operations    |
| `Monitor`       | Watch a background script, react to output events |
| `Glob`          | Find files by pattern                             |
| `Grep`          | Search file contents with regex                   |
| `WebSearch`     | Search the web                                    |
| `WebFetch`      | Fetch and parse web pages                         |
| `AskUserQuestion` | Ask user clarifying questions                  |
| `Agent`         | Spawn subagents                                   |

### Permission modes

| Mode                | Behavior                                                      |
| :------------------ | :------------------------------------------------------------ |
| `default`           | Unmatched tools trigger `canUseTool` callback                 |
| `dontAsk`           | Deny anything not in `allowedTools`; `canUseTool` never called |
| `acceptEdits`       | Auto-approve file edits and filesystem ops                    |
| `bypassPermissions` | All tools run without prompts (use in sandboxed envs)         |
| `plan`              | No tool execution; planning only                              |
| `auto` (TS only)    | Model classifier approves/denies each call                    |

Permission evaluation order: Hooks -> Deny rules -> Permission mode -> Allow rules -> `canUseTool` callback.

### Permission options

| Option (Python / TS)                      | Effect                                                  |
| :---------------------------------------- | :------------------------------------------------------ |
| `allowed_tools` / `allowedTools`          | Pre-approve listed tools (unlisted fall through)         |
| `disallowed_tools` / `disallowedTools`    | Always deny listed tools (even in `bypassPermissions`)   |

### Hooks

Callback functions that intercept agent events. Register via `options.hooks`.

| Hook event          | When it fires                      | Common use                              |
| :------------------ | :--------------------------------- | :-------------------------------------- |
| `PreToolUse`        | Before a tool executes             | Block, modify input, require approval   |
| `PostToolUse`       | After a tool returns               | Log, audit, transform output            |
| `Stop`              | Agent finishes                     | Cleanup, notifications                  |
| `SessionStart`      | Session begins                     | Initialize state                        |
| `SessionEnd`        | Session ends                       | Cleanup resources                       |
| `UserPromptSubmit`  | User prompt received               | Validate input                          |

Hooks use `matcher` patterns (e.g. `"Write|Edit"`) to filter by tool name. Return `permissionDecision: "deny"` to block.

### Sessions

| Approach                     | How                                                          | Use case                        |
| :--------------------------- | :----------------------------------------------------------- | :------------------------------ |
| One-shot                     | Single `query()` call                                         | Independent tasks               |
| Continue (most recent)       | `continue_conversation=True` / `continue: true`              | Multi-turn, one conversation    |
| Resume (specific session)    | Pass `session_id` / `resume`                                  | Multi-session apps              |
| Fork                         | Pass `fork` with session ID                                   | Try alternative approaches      |
| No persistence (TS only)     | `persistSession: false`                                       | Stateless tasks                 |

### Subagents

Define via `agents` parameter in options or `.claude/agents/*.md` files. Include `Agent` in `allowedTools`.

| Field         | Purpose                                                |
| :------------ | :----------------------------------------------------- |
| `description` | When Claude should use this agent                       |
| `prompt`      | System instructions for the subagent                    |
| `tools`       | Tool allowlist (restricts available tools)              |

Subagents run in isolated context; only final message returns to parent. Can run in parallel.

### Custom tools

Define with `@tool` decorator (Python) or `tool()` helper (TypeScript). Wrap in `create_sdk_mcp_server` / `createSdkMcpServer` and pass to `mcpServers`.

### MCP servers

| Transport | Config key | Use case                                |
| :-------- | :--------- | :-------------------------------------- |
| `stdio`   | `command`, `args` | Local process (e.g. `npx @playwright/mcp@latest`) |
| `http`    | `type: "http"`, `url` | Remote servers                   |
| In-process | `createSdkMcpServer` | Custom tools in your app         |

Tool naming: `mcp__<server-name>__<tool-name>`. Wildcard: `mcp__<server>__*`.

### Structured outputs

Pass `output_format` / `outputFormat` with a JSON Schema (or Zod/Pydantic). Result includes `structured_output` field with validated data.

### Streaming output

Set `include_partial_messages` / `includePartialMessages` to `true`. Yields `StreamEvent` messages with raw API events (`content_block_delta` with `text_delta`).

### Key options

| Option (Python / TS)                    | Purpose                                          |
| :-------------------------------------- | :----------------------------------------------- |
| `system_prompt` / `systemPrompt`        | Custom system prompt                              |
| `max_turns` / `maxTurns`               | Cap tool-use turns                                |
| `max_budget_usd` / `maxBudgetUsd`      | Spend threshold                                   |
| `cwd`                                   | Working directory                                 |
| `model`                                 | Model override                                    |
| `mcp_servers` / `mcpServers`            | MCP server configuration                          |
| `setting_sources` / `settingSources`    | Control which config sources load                 |
| `output_format` / `outputFormat`        | Structured output schema                          |

### Hosting requirements

| Requirement      | Details                                              |
| :--------------- | :--------------------------------------------------- |
| Runtime          | Python 3.10+ or Node.js 18+                          |
| Resources        | 1 GiB RAM, 5 GiB disk, 1 CPU (recommended)           |
| Network          | Outbound HTTPS to `api.anthropic.com`                 |
| Sandbox          | Container-based isolation recommended for production  |

Sandbox providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox.

### SDK vs CLI vs Client SDK

| Use case                | Best choice  |
| :---------------------- | :----------- |
| Interactive development | CLI          |
| CI/CD pipelines         | Agent SDK    |
| Custom applications     | Agent SDK    |
| One-off tasks           | CLI          |
| Direct API access       | Client SDK   |
| Production automation   | Agent SDK    |

### TypeScript V2 preview

Simplified interface with `send()` and `stream()` patterns for easier multi-turn conversations.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) -- capabilities, installation, getting started, SDK vs CLI vs Client SDK comparison
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) -- build a bug-fixing agent in minutes, key concepts, troubleshooting
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) -- message lifecycle, turns, message types, context window, compaction, cost tracking
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) -- skills, slash commands, memory, plugins via the SDK
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) -- monitoring token usage and costs
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) -- define tools with in-process MCP servers, schemas, handlers, annotations
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) -- snapshot and revert file changes
- [Hooks](references/claude-code-agent-sdk-hooks.md) -- intercept and control agent behavior at execution points
- [Hosting](references/claude-code-agent-sdk-hosting.md) -- deploy to Docker, cloud, CI/CD; sandbox providers; architecture
- [MCP](references/claude-code-agent-sdk-mcp.md) -- connect to external tools via Model Context Protocol
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) -- migrate from Claude Code SDK to Agent SDK
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) -- customize agent instructions
- [Observability](references/claude-code-agent-sdk-observability.md) -- OpenTelemetry integration, tracing, monitoring
- [Permissions](references/claude-code-agent-sdk-permissions.md) -- permission modes, allow/deny rules, evaluation flow
- [Plugins](references/claude-code-agent-sdk-plugins.md) -- extend agents with plugins
- [Python SDK reference](references/claude-code-agent-sdk-python.md) -- complete Python API: query, ClaudeSDKClient, types, options
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) -- step-by-step setup and first agent
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) -- security hardening, network controls, isolation
- [Sessions](references/claude-code-agent-sdk-sessions.md) -- continue, resume, fork sessions; multi-turn context
- [Skills](references/claude-code-agent-sdk-skills.md) -- use skills in SDK agents
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) -- custom commands for SDK agents
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) -- real-time token streaming
- [Streaming vs single-turn](references/claude-code-agent-sdk-streaming-vs-single-mode.md) -- input modes comparison
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) -- JSON Schema, Zod, Pydantic validated outputs
- [Subagents](references/claude-code-agent-sdk-subagents.md) -- define, invoke, and configure subagents
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) -- task tracking in SDK agents
- [Tool search](references/claude-code-agent-sdk-tool-search.md) -- load tools on demand for large tool sets
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) -- complete TypeScript API: query, startup, types, options
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) -- simplified send/stream interface
- [User input](references/claude-code-agent-sdk-user-input.md) -- handle approvals, AskUserQuestion, canUseTool callback

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
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single-turn: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
