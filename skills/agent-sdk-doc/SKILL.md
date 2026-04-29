---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building production AI agents with Python and TypeScript, agent loop architecture, tool execution, permissions, sessions, hooks, MCP servers, custom tools, subagents, streaming, cost tracking, observability, file checkpointing, secure deployment, migrations, and API reference for both SDKs.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK, Anthropic's library for building production AI agents with programmatic control over tools, permissions, cost limits, and output.

## Quick Reference

The Agent SDK gives you Claude with built-in tool execution. Use it to build agents that autonomously read files, run commands, search the web, and edit code—without implementing your own tool loop.

### Installation

| Language | Command |
| :--- | :--- |
| **Python** | `pip install claude-agent-sdk` |
| **TypeScript** | `npm install @anthropic-ai/claude-agent-sdk` |

### Main entry points

| Function | Purpose |
| :--- | :--- |
| `query()` | Create a new session for each interaction |
| `ClaudeSDKClient` (Python) | Maintain conversation state across multiple turns |
| `startup()` (TypeScript) | Pre-warm the subprocess before sending prompts |

### Built-in tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| **File operations** | Read, Edit, Write | Read, modify, and create files |
| **Search** | Glob, Grep | Find files by pattern, search with regex |
| **Execution** | Bash | Run shell commands, git operations |
| **Web** | WebSearch, WebFetch | Search the web, fetch and parse pages |
| **Discovery** | ToolSearch | Load tools on-demand instead of preloading all |
| **Orchestration** | Agent, Skill, AskUserQuestion, TodoWrite | Spawn subagents, invoke skills, ask users, track tasks |

### Permission modes

| Mode | Behavior |
| :--- | :--- |
| `default` | No auto-approvals; unmatched tools trigger your callback |
| `dontAsk` | Deny instead of prompting; anything not pre-approved is blocked |
| `acceptEdits` | Auto-approve file edits and filesystem operations |
| `bypassPermissions` | Run all tools without prompts (CI/isolated environments only) |
| `plan` | No tool execution; Claude plans without making changes |
| `auto` (TypeScript only) | Model-classified approvals |

### Key options

| Option | Type | Purpose |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `string[]` | Pre-approve specific tools (no permission prompt) |
| `disallowed_tools` / `disallowedTools` | `string[]` | Block specific tools (deny rules always win) |
| `permission_mode` / `permissionMode` | string | Global permission behavior (see Permission modes above) |
| `max_turns` / `maxTurns` | number | Maximum tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | number | Maximum cost before stopping (in USD) |
| `effort` | string | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `system_prompt` / `systemPrompt` | string | Custom system instructions for the agent |
| `setting_sources` / `settingSources` | `string[]` | Load CLAUDE.md, skills, hooks from directories |
| `mcp_servers` / `mcpServers` | object | Connect external services via Model Context Protocol |
| `hooks` | object | Run callbacks at key lifecycle points |
| `agents` / custom agents | object | Define specialized subagents |
| `resume` / continue session | string | Resume from a previous session ID |

### Message types

| Type | Emitted when | Contains |
| :--- | :--- | :--- |
| `SystemMessage` | Session lifecycle events | Session ID, init/compaction events |
| `AssistantMessage` | Claude responds | Text content and tool call requests |
| `UserMessage` | Tool executes | Tool result sent back to Claude |
| `StreamEvent` | Partial messages enabled | Text deltas, tool input chunks (real-time streaming) |
| `ResultMessage` | Loop ends | Final text, token usage, cost, session ID, result subtype |

Result subtypes: `success`, `error_max_turns`, `error_max_budget_usd`, `error_during_execution`, `error_max_structured_output_retries`

### Permission evaluation flow

1. **Hooks** — Run first; can allow, deny, or continue
2. **Deny rules** — Check `disallowed_tools` (blocks regardless of mode)
3. **Permission mode** — Apply global behavior
4. **Allow rules** — Check `allowed_tools`
5. **Callback** — Call `canUseTool` callback if not resolved

### Context window and compaction

- **Accumulates over turns:** system prompt, tool definitions, conversation history (all in one context)
- **Automatic compaction:** when approaching limit, SDK summarizes older history to free space
- **Control via CLAUDE.md:** include "summary instructions" section to tell compactor what to preserve
- **Manual compaction:** send `/compact` as a prompt

### Sessions and continuity

- Capture `session_id` from `ResultMessage` to resume later
- Resume restores full context from previous turns
- Fork a session to branch into different approaches without modifying the original

### Custom tools

Define your own tools via the in-process MCP server:

| Pattern | Details |
| :--- | :--- |
| Define | Use `@tool` decorator (Python) or `tool()` function (TypeScript) with name, description, input schema, handler |
| Register | Wrap in `create_sdk_mcp_server` / `createSdkMcpServer`, pass to `mcpServers` |
| Pre-approve | Add to `allowed_tools` (format: `mcp__{server}__{tool_name}`) |
| Return | Content array with `type: "text"`, `"image"`, or `"resource"` |
| Error handling | Return `isError: true` instead of throwing to keep loop alive |

### Hooks (lifecycle callbacks)

| Hook | When it fires | Common uses |
| :--- | :--- | :--- |
| `PreToolUse` | Before a tool executes | Validate, block dangerous commands |
| `PostToolUse` | After a tool returns | Audit outputs, trigger side effects |
| `UserPromptSubmit` | When a prompt is sent | Inject context |
| `Stop` | When agent finishes | Validate result, save state |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle | Track parallel task results |
| `PreCompact` | Before context compaction | Archive full transcript |

Hooks run in your application (not in context), so they don't consume tokens.

### Subagents

Spawn specialized agents for subtasks:

```
Main agent → Define custom agents via AgentDefinition → Spawn via Agent tool → Results return to main agent
```

- Fresh conversation per subagent (no parent history visible)
- Only final response returns as a tool result
- Main agent's context grows by summary, not full subtask transcript
- Use to keep main context lean on long-running tasks

### Streaming modes

| Mode | Use case |
| :--- | :--- |
| **Single-turn** (default) | Collect all messages, return final result (batch/CI jobs) |
| **Streaming** | Iterate `async for` to see progress in real-time (interactive UIs) |
| **Partial messages** | Enable `include_partial_messages` for text deltas and tool input chunks |

### Cost tracking

- `ResultMessage.total_cost_usd` — total session cost in USD
- `ResultMessage.usage` — token counts: `input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`
- Check result subtype to handle budget overruns: `error_max_budget_usd`

### Python vs TypeScript differences

| Feature | Python | TypeScript |
| :--- | :--- | :--- |
| **Message types** | `isinstance(msg, ResultMessage)` | `msg.type === "result"` |
| **Nested message** | Message itself | Wrapped in `.message` field |
| **Interrupt support** | Not yet | Yes (via `ClaudeSDKClient`) |
| **Tool annotations** | `ToolAnnotations` class | `annotations` option object |
| **Session management** | `ClaudeSDKClient` reuses sessions | Both `query()` and client support |

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — introduction, installation, get started, capabilities (tools, hooks, subagents, MCP, permissions, sessions), Claude Code features, comparison with other Claude tools, branding guidelines, license
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — setup, create buggy code, build a bug-fixing agent, run it, customize, key concepts, troubleshooting
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — message lifecycle, turns, tool execution, parallel execution, control loop behavior (turns, budget, effort, permission mode, model), context window, compaction, sessions, result handling, hooks, complete example
- [Agent SDK reference - Python](references/claude-code-agent-sdk-python.md) — `query()` and `ClaudeSDKClient` comparison, installation, functions (`query`, `tool`, `create_sdk_mcp_server`), `ClaudeAgentOptions`, message types, hooks, exceptions
- [Agent SDK reference - TypeScript](references/claude-code-agent-sdk-typescript.md) — installation, functions (`query`, `startup`, `tool`, `createSdkMcpServer`), `Options` type, message types, `WarmQuery` for pre-warming, hooks, exceptions
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — define tools, call custom tools, add more tools, tool annotations, control tool access, handle errors, return images and resources, unit converter example
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — how permissions are evaluated (hooks → deny rules → permission mode → allow rules → callback), allow and deny rules, permission modes, pattern matching rules
- [Connect external services with MCP](references/claude-code-agent-sdk-mcp.md) — what is MCP, connecting MCP servers, tool search for on-demand loading, configuring servers, environment variables, debugging
- [Sessions and continuity](references/claude-code-agent-sdk-sessions.md) — capture session IDs, resume sessions, fork sessions, session checkpointing
- [Run custom code with hooks](references/claude-code-agent-sdk-hooks.md) — hook lifecycle, available hooks (PreToolUse, PostToolUse, UserPromptSubmit, Stop, SubagentStart, SubagentStop, PreCompact, more), hook signatures, error handling, hook context
- [Use subagents for focused tasks](references/claude-code-agent-sdk-subagents.md) — define subagents, spawn subagents, what subagents inherit, limitations, tracking results
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — streaming vs single-turn, enable streaming, partial messages, stream event types, progress reporting
- [Streaming vs. single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use each, collecting messages, handling the result
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback for approval, `AskUserQuestion` tool for clarifications, dynamic tool lists
- [Track costs and tokens](references/claude-code-agent-sdk-cost-tracking.md) — token counting, cost calculation, budgeting strategies
- [Load CLAUDE.md and project skills](references/claude-code-agent-sdk-claude-code-features.md) — `setting_sources` option, loading from project/user/system directories, skills, slash commands, memory, plugins
- [Define and invoke skills](references/claude-code-agent-sdk-skills.md) — skill structure, invoking skills from agents, creating skills, skill context
- [Use slash commands](references/claude-code-agent-sdk-slash-commands.md) — built-in commands, sending slash commands from SDK, custom commands
- [Return structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — structured output validation, error handling, retries, streaming structured outputs
- [Enable observability](references/claude-code-agent-sdk-observability.md) — logging, tracing, debugging, performance monitoring
- [Checkpoint sessions to files](references/claude-code-agent-sdk-file-checkpointing.md) — save and restore sessions, checkpoint format
- [Deploy securely](references/claude-code-agent-sdk-secure-deployment.md) — authentication, sandboxing, network isolation, secrets management
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — upgrading from Claude Code SDK to Agent SDK
- [Modify system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom system prompt patterns, prompt injection protection
- [Plugins and integrations](references/claude-code-agent-sdk-plugins.md) — defining plugins, plugin manifest, marketplace integration
- [Host agents in production](references/claude-code-agent-sdk-hosting.md) — Docker deployment, cloud platforms (AWS, GCP, Azure), CI/CD, error handling, monitoring
- [Tool search for on-demand loading](references/claude-code-agent-sdk-tool-search.md) — dynamically discover and load tools, tool search configuration
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — simplified `send()` and `stream()` patterns, multi-turn conversations, new interface

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Agent SDK reference - Python: https://code.claude.com/docs/en/agent-sdk/python.md
- Agent SDK reference - TypeScript: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Connect external services with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Sessions and continuity: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Run custom code with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Use subagents for focused tasks: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs. single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Track costs and tokens: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Load CLAUDE.md and project skills: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Define and invoke skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Use slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Return structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Enable observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Checkpoint sessions to files: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Deploy securely: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- Modify system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Plugins and integrations: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Host agents in production: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Tool search for on-demand loading: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
