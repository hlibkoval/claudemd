---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — overview, quickstart, agent loop internals, Python and TypeScript API references, sessions, streaming, custom tools, subagents, hooks, permissions, MCP, plugins, skills, slash commands, structured outputs, cost tracking, observability, file checkpointing, todo tracking, tool search, hosting, system prompt modification, secure deployment, migration guide, and Claude Code feature integration.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the library for building production AI agents powered by Claude Code's agent loop.

## Quick Reference

### Installation

| Language | Package | Install |
| :--- | :--- | :--- |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |

Migration note: previously `claude-code-sdk` (Python) and `@anthropic-ai/claude-code` (TS) — see migration guide.

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New each time | Reuses same session |
| Conversation | Single exchange | Multi-turn, same context |
| Interrupts | No | Yes |
| Use case | One-off tasks | Interactive / continuous |

### TypeScript: `query()` and `startup()`

| Function | Purpose |
| :--- | :--- |
| `query({ prompt, options })` | Primary async generator; streams messages |
| `startup({ options, initializeTimeoutMs })` | Pre-warms CLI subprocess; returns `WarmQuery` |

TypeScript V2 preview adds simplified `send()` and `stream()` patterns for multi-turn conversations.

### Agent loop steps

1. **Receive prompt** → SDK yields `SystemMessage` subtype `"init"` with session metadata
2. **Evaluate** → Claude responds with text and/or tool call requests (`AssistantMessage`)
3. **Execute tools** → SDK runs tools; hooks can intercept/modify/block
4. **Repeat** → continues until Claude produces output with no tool calls
5. **Return result** → final `AssistantMessage` + `ResultMessage` (text, tokens, cost, session ID)

### Key `ClaudeAgentOptions` / `Options` fields

| Field | Description |
| :--- | :--- |
| `allowedTools` | Restrict which built-in tools are available |
| `model` | Override the Claude model |
| `maxTurns` | Cap the number of agent loop turns |
| `systemPrompt` | Append or replace the system prompt |
| `permissionMode` | `"auto"`, `"prompt"`, or `"bypassPermissions"` |
| `cwd` | Working directory for the agent |
| `env` | Environment variables passed to the subprocess |

### Message types

| Type | Subtype | Content |
| :--- | :--- | :--- |
| `SystemMessage` | `"init"` | Session ID, model, tools, cost limits |
| `AssistantMessage` | — | Text content + tool call requests |
| `ToolResultMessage` | — | Results of executed tools |
| `ResultMessage` | — | Final text, token usage, cost, session ID |

### Secure deployment: isolation options

| Technology | Isolation strength | Overhead | Complexity |
| :--- | :--- | :--- | :--- |
| Sandbox runtime | Good | Very low | Low |
| Docker containers | Setup-dependent | Low | Medium |
| gVisor | Excellent | Medium/High | Medium |
| VMs (Firecracker/QEMU) | Excellent | High | Medium/High |

Key principles: isolation, least privilege, defense in depth. Use a credential proxy rather than exposing API keys directly to the agent.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — introduction, capabilities, and getting-started cards
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — build a bug-fixing agent in Python or TypeScript step-by-step
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — turns, messages, tool execution, context window, and architecture
- [Python API reference](references/claude-code-agent-sdk-python.md) — full reference for `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, and all types
- [TypeScript API reference](references/claude-code-agent-sdk-typescript.md) — full reference for `query()`, `startup()`, `Options`, `Query`, `WarmQuery`, and all types
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — simplified `send()` / `stream()` multi-turn API
- [Sessions](references/claude-code-agent-sdk-sessions.md) — session lifecycle, resuming, and multi-session management
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — streaming prompts and incremental message handling
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — tradeoffs and when to use each
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — defining and registering custom tools for agents
- [Subagents](references/claude-code-agent-sdk-subagents.md) — spawning and coordinating child agents
- [Hooks](references/claude-code-agent-sdk-hooks.md) — intercepting tool calls and agent events in SDK context
- [Permissions](references/claude-code-agent-sdk-permissions.md) — configuring `permissionMode` and tool allow/deny rules
- [MCP](references/claude-code-agent-sdk-mcp.md) — connecting MCP servers to SDK agents
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading plugins in SDK agents
- [Skills](references/claude-code-agent-sdk-skills.md) — using skills in SDK agents
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — invoking slash commands programmatically
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — getting typed JSON responses from agents
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — monitoring token usage and spend per session
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry integration for SDK agents
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — saving and restoring agent state across file edits
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — using the TodoWrite/TodoRead tools in SDK agents
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferred tool schemas and the ToolSearch pattern
- [Hosting](references/claude-code-agent-sdk-hosting.md) — deployment environments and infrastructure considerations
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — appending, prepending, or replacing the default system prompt
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — isolation, least privilege, credential management, and network controls
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — which Claude Code built-in features are available in SDK agents
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from `claude-code-sdk` / `@anthropic-ai/claude-code` to the Agent SDK

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
- Python API reference: https://code.claude.com/docs/en/agent-sdk/python.md
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
- TypeScript API reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
