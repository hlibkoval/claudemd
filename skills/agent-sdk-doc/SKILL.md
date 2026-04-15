---
name: agent-sdk-doc
description: Claude Agent SDK documentation for building production AI agents in Python and TypeScript using the same agent loop, tools, and context management that power Claude Code.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (Python and TypeScript), which lets you build autonomous agents that read files, run commands, search the web, edit code, and more, programmatically.

## Quick Reference

### Install and authenticate

| Language | Install | Auth |
| --- | --- | --- |
| Python | `pip install claude-agent-sdk` (Python 3.10+) | `ANTHROPIC_API_KEY` env var |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` (Node 18+) | `ANTHROPIC_API_KEY` env var |

Third-party providers: set `CLAUDE_CODE_USE_BEDROCK=1`, `CLAUDE_CODE_USE_VERTEX=1`, or `CLAUDE_CODE_USE_FOUNDRY=1` and configure the corresponding cloud credentials.

### Core API surface

| Entry point | Language | Use case |
| --- | --- | --- |
| `query()` | Python and TypeScript | One-shot prompt; returns an async iterator of messages. Each call is a fresh session. |
| `ClaudeSDKClient` | Python | Continuous, multi-turn conversation with manual connection control; supports interrupts. |
| V2 `send()` / `stream()` | TypeScript (preview) | Simplified session-based API for multi-turn chats. |
| `tool()` | TypeScript | Type-safe MCP tool definition for in-process SDK MCP servers. |
| `@tool` / `create_sdk_mcp_server` | Python | Define custom in-process MCP tools. |
| `HookMatcher` / `HookCallback` | Both | Register lifecycle hooks. |
| `AgentDefinition` | Both | Define a subagent inline. |

### Built-in tools

| Tool | Purpose |
| --- | --- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run shell commands, scripts, git operations |
| `Monitor` | Watch a background script and react to each output line |
| `Glob` | Find files by pattern (e.g. `**/*.ts`) |
| `Grep` | Regex search inside file contents |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user a multiple-choice clarifying question |
| `Agent` | Invoke a configured subagent (must be in `allowed_tools`) |

### Common `ClaudeAgentOptions` fields

| Field (Python / TS) | Purpose |
| --- | --- |
| `allowed_tools` / `allowedTools` | Pre-approve a list of tool names |
| `disallowed_tools` / `disallowedTools` | Block tools regardless of mode |
| `permission_mode` / `permissionMode` | Permission strategy (see below) |
| `system_prompt` / `systemPrompt` | Override or append to the system prompt |
| `mcp_servers` / `mcpServers` | Connect external MCP servers |
| `hooks` | Map of lifecycle hook callbacks |
| `agents` | Map of `AgentDefinition` subagents |
| `setting_sources` / `settingSources` | Load filesystem config (e.g. `["project"]` for `.claude/`, `CLAUDE.md`) |
| `resume` | Resume a prior session by ID |
| `max_turns` / `maxTurns` | Cap tool-use turns |
| `max_budget_usd` / `maxBudgetUsd` | Cap total spend |
| `plugins` | Programmatic plugin loading |

### Permission modes

| Mode | Behavior |
| --- | --- |
| `default` | Calls your `canUseTool` callback for anything not pre-approved |
| `acceptEdits` | Auto-approves file edits and common filesystem commands |
| `dontAsk` | Denies anything not in `allowedTools`; never prompts |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call |
| `bypassPermissions` | Runs every tool with no prompts (sandboxed/CI use only) |

Permission evaluation order: hooks → deny rules → permission mode → allow rules → `canUseTool` callback.

### Lifecycle hooks

`PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, `SessionEnd`, `UserPromptSubmit`, and more. Each hook receives the tool input and can allow, deny, or transform the call.

### Message types streamed by `query()`

| Type | Meaning |
| --- | --- |
| `SystemMessage` (subtype `init`) | Session metadata, including `session_id` |
| `SystemMessage` (subtype `compact_boundary`) | Auto-compaction occurred |
| `AssistantMessage` | Claude text and/or tool-use blocks |
| `UserMessage` | Tool results fed back to Claude |
| `ResultMessage` | Final text, token usage, cost, session ID |

### When to use what

| Goal | Use |
| --- | --- |
| One-off task in Python | `query()` |
| Multi-turn chat in Python | `ClaudeSDKClient` |
| One-off task in TypeScript | `query()` |
| Multi-turn chat in TypeScript | V2 preview `send()` / `stream()` |
| Add domain logic | Custom tools via in-process MCP server |
| Connect external service | `mcpServers` (stdio, SSE, HTTP) |
| Delegate a focused subtask | `agents` + `Agent` tool |
| Validated JSON output | Structured outputs (JSON Schema / Zod / Pydantic) |
| Scale to thousands of tools | Tool search |
| Ship to production | Hosting + secure deployment + observability |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — High-level introduction, capabilities, install steps, and comparison to the Client SDK and Claude Code CLI.
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent end to end in Python or TypeScript.
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turns, context window, compaction, and architecture.
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — Load `CLAUDE.md`, skills, slash commands, and other filesystem config via `setting_sources`.
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — Token tracking, deduplication of parallel tool calls, and cost calculation.
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — Define custom tools with the in-process MCP server.
- [Rewind file changes with checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Track and roll back file changes during a session.
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — Lifecycle hook reference and patterns.
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — Deploy and operate the SDK in production.
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — MCP transports, tool search, auth, and error handling.
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — Migration guide from the legacy Claude Code SDK.
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Output styles, append-mode, and fully custom system prompts.
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — Export traces, metrics, and events via OTel.
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — Permission modes, allow/deny rules, and the evaluation flow.
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — Load plugins to extend agents with commands, agents, skills, and hooks.
- [Agent SDK reference - Python](references/claude-code-agent-sdk-python.md) — Complete Python API reference: functions, types, and classes.
- [Securely deploying AI agents](references/claude-code-agent-sdk-secure-deployment.md) — Isolation, credential management, and network controls for production deployments.
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — Session persistence, continue, resume, and fork.
- [Agent Skills in the SDK](references/claude-code-agent-sdk-skills.md) — Use Agent Skills as specialized capabilities loaded by the SDK.
- [Slash Commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — Invoke slash commands from SDK sessions.
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — Real-time text and tool-call streaming.
- [Streaming Input](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming vs. single-turn input modes and when to choose each.
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — Validated JSON output via JSON Schema, Zod, or Pydantic.
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — Define and invoke subagents for isolated, parallel, or specialized work.
- [Todo Lists](references/claude-code-agent-sdk-todo-tracking.md) — Track and display todos in agent runs.
- [Scale to many tools with tool search](references/claude-code-agent-sdk-tool-search.md) — Discover and load tools on demand to handle large tool sets.
- [Agent SDK reference - TypeScript](references/claude-code-agent-sdk-typescript.md) — Complete TypeScript API reference: functions, types, and interfaces.
- [TypeScript SDK V2 interface (preview)](references/claude-code-agent-sdk-typescript-v2-preview.md) — Simplified V2 TypeScript interface with session-based `send()` / `stream()` patterns.
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — Surface approval requests and clarifying questions to end users.

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Rewind file changes with checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Agent SDK reference - Python: https://code.claude.com/docs/en/agent-sdk/python.md
- Securely deploying AI agents: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Agent Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash Commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming Input: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo Lists: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Scale to many tools with tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Agent SDK reference - TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript SDK V2 interface (preview): https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
