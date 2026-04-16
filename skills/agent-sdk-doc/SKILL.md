---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK (Python and TypeScript) — the agent loop, built-in and custom tools, hooks, permissions, subagents, sessions, MCP integration, skills, slash commands, cost tracking, system prompts, streaming, structured outputs, hosting, secure deployment, and observability.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — Claude Code's autonomous agent loop, tools, and context management packaged as a programmable library for Python and TypeScript.

## Quick Reference

### Install and run

| Language | Install | Minimal example |
|---|---|---|
| Python | `pip install claude-agent-sdk` | `async for m in query(prompt=..., options=ClaudeAgentOptions(allowed_tools=[...])): ...` |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | `for await (const m of query({ prompt, options: { allowedTools: [...] } })) { ... }` |

Auth: `ANTHROPIC_API_KEY`, or `CLAUDE_CODE_USE_BEDROCK=1` / `CLAUDE_CODE_USE_VERTEX=1` / `CLAUDE_CODE_USE_FOUNDRY=1` for third-party providers. Claude.ai login is not permitted for third-party agents. The old "Claude Code SDK" has been renamed to "Claude Agent SDK"; see the migration guide.

### `query()` core options (Python snake_case / TS camelCase)

| Option | Purpose |
|---|---|
| `allowed_tools` / `allowedTools` | Auto-approve listed tools (e.g. `["Read", "Edit", "Bash(npm:*)"]`) |
| `disallowed_tools` / `disallowedTools` | Always deny listed tools (wins over every mode) |
| `permission_mode` / `permissionMode` | How un-ruled tools are handled — see below |
| `system_prompt` / `systemPrompt` | Minimal by default; use `{"type":"preset","preset":"claude_code"}` for full Claude Code prompt |
| `setting_sources` / `settingSources` | `["project","user","local"]` — needed to load CLAUDE.md, skills, slash commands, filesystem hooks |
| `mcp_servers` / `mcpServers` | Stdio, SSE, HTTP, or in-process SDK servers |
| `hooks` | Callback map keyed by event name |
| `agents` | Programmatic subagent definitions (requires `Agent` in allowed tools) |
| `max_turns` / `maxTurns` | Cap tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | Stop when estimated spend exceeds threshold |
| `effort` | `"low"` / `"medium"` / `"high"` / `"max"` (TS defaults to `"high"`) |
| `model` | Pin a model ID; otherwise SDK default |
| `resume` / `fork_session` | Continue or branch a session by ID |
| `include_partial_messages` / `includePartialMessages` | Emit `StreamEvent` deltas |
| `can_use_tool` / `canUseTool` | Runtime approval callback (required in `default` mode) |
| `plugins` | Register plugins programmatically |

### Permission modes

| Mode | Behavior |
|---|---|
| `default` | Un-ruled tools hit `canUseTool`; no callback means deny |
| `acceptEdits` | Auto-approves file edits and common FS commands (`mkdir`, `touch`, `mv`, `cp`); other Bash falls through |
| `plan` | No tool execution — Claude produces a plan only |
| `dontAsk` | Only allow-ruled tools run; everything else denied silently |
| `auto` (TS only) | Model classifier approves/denies each call |
| `bypassPermissions` | Run everything. Not allowed as root on Unix. Isolated envs only |

Evaluation order: hooks → deny rules → mode → allow rules → `canUseTool`.

### Built-in tools

| Category | Tools |
|---|---|
| Files | `Read`, `Edit`, `Write` |
| Search | `Glob`, `Grep` |
| Execution | `Bash`, `Monitor` |
| Web | `WebSearch`, `WebFetch` |
| Discovery | `ToolSearch` (load tools on-demand) |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite` |

Read-only tools run in parallel; mutating tools run sequentially. Mark custom tools `readOnlyHint: true` (Python) / `readOnly` (TS) to opt into parallelism.

### Message types (streamed from `query()`)

| Type | Emitted when | Key fields |
|---|---|---|
| `SystemMessage` (`subtype:"init"`) | Session start | session ID, model, cwd, tool list |
| `SystemMessage` / `SDKCompactBoundaryMessage` (`subtype:"compact_boundary"`) | Auto-compaction ran | trigger |
| `AssistantMessage` | After each Claude response | text + tool-use blocks, token usage |
| `UserMessage` | After each tool execution or mid-loop user input | tool results |
| `StreamEvent` | Only with partial messages enabled | raw API deltas |
| `ResultMessage` | Final, always | `subtype`, `result`, `total_cost_usd`, `usage`, `num_turns`, `session_id`, `stop_reason` |

`ResultMessage.subtype`: `success`, `error_max_turns`, `error_max_budget_usd`, `error_during_execution`, `error_max_structured_output_retries`. `result` text is only present on `success`.

### Hooks

| Event | Fires |
|---|---|
| `PreToolUse` | Before a tool executes (can deny, modify input) |
| `PostToolUse` | After a tool returns (audit, side effects) |
| `UserPromptSubmit` | User prompt submitted (inject context) |
| `Stop` | Agent finishes the loop |
| `SessionStart` / `SessionEnd` | Session lifecycle |
| `SubagentStart` / `SubagentStop` | Subagent spawn/finish |
| `PreCompact` | Before auto or manual compaction |
| `Notification` | Permission prompts, idle, etc. |

Callbacks take `(input_data, tool_use_id, context)` and return `{}` to allow or `{"hookSpecificOutput": {"permissionDecision": "deny", "permissionDecisionReason": ...}}` to block. Hooks run in your process and do not consume context.

### System prompt modes

| Form | Effect |
|---|---|
| Omitted | Minimal default — tool instructions only |
| `{"type":"preset","preset":"claude_code"}` | Full Claude Code prompt (still does NOT auto-load CLAUDE.md — set `setting_sources` too) |
| `{"type":"preset","preset":"claude_code","append":"..."}` | Claude Code preset plus your extra instructions |
| String | Fully custom system prompt (replaces the default) |

CLAUDE.md loads only when `setting_sources` includes `"project"` or `"user"`. Persistent rules belong there, not the initial prompt, because compaction can discard early user messages.

### Cost tracking

- Per-step token counts: TS `message.message.usage` + `message.message.id`; Python `message.usage` + `message.message_id`. Deduplicate by message ID — parallel tools in one turn share an ID.
- Per-query total: `ResultMessage.total_cost_usd` + `usage` dict. Per-model breakdown: `modelUsage` (TS) / `model_usage` (Python).
- `total_cost_usd` is a **client-side estimate** from a bundled price table, not authoritative billing. Use the Usage and Cost API for billing truth.
- Sessions: each `query()` call reports its own cost independently; sum them across session IDs.

### Custom tools (in-process MCP)

1. Define with `@tool` (Python) or `tool()` (TS) — name, description, input schema (Zod in TS, type dict or JSON Schema in Python), async handler returning `{ content: [...], isError? }`.
2. Wrap with `create_sdk_mcp_server` / `createSdkMcpServer`.
3. Pass via `mcp_servers` / `mcpServers`.
4. Pre-approve by listing `mcp__<server>__<tool>` in allowed tools.
5. Return `isError: true` to signal failure without throwing. Return `image` or `resource` content blocks for non-text output.

### Subagents

Defined programmatically via `agents={ name: AgentDefinition(description, prompt, tools, model?) }` or via filesystem (`.claude/agents/*.md` with `setting_sources=["project"]`). Invoked through the `Agent` tool — include it in `allowed_tools`. Each subagent starts with a fresh conversation but inherits project-level context; only its final response returns to the parent. Messages inside a subagent carry `parent_tool_use_id`.

### Sessions

| Op | How |
|---|---|
| Capture ID | `SystemMessage` init (TS: `message.session_id`; Python: `message.data["session_id"]`) or `ResultMessage.session_id` |
| Resume | `options.resume = session_id` |
| Fork | `options.fork_session = True` with resume ID |
| Continuous client | Python `ClaudeSDKClient` auto-manages IDs across calls |

### Streaming vs single-mode

| Mode | When |
|---|---|
| Streaming input (recommended) | Async generator of messages; supports interruptions, images, mid-loop input, `AskUserQuestion` |
| Single message | Pass a string prompt; use `resume` across calls for multi-turn. Best for stateless CI jobs |

Enable `include_partial_messages` / `includePartialMessages` for real-time text deltas via `StreamEvent`.

### Claude Code filesystem features (require `setting_sources`)

| Feature | Location |
|---|---|
| Skills | `.claude/skills/*/SKILL.md` |
| Slash commands | `.claude/commands/*.md` (and plugin commands) |
| Memory / CLAUDE.md | `CLAUDE.md`, `.claude/CLAUDE.md`, `~/.claude/CLAUDE.md` |
| Filesystem hooks | `.claude/settings.json` hooks section |
| Plugins | via `plugins` option or marketplaces |

### Agent SDK vs Client SDK

Client SDK: you implement the tool loop. Agent SDK: Claude runs the loop for you with built-in tools, permissions, sessions, hooks, and compaction.

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — What the SDK is, capabilities (tools, hooks, subagents, MCP, permissions, sessions), auth options, and Agent SDK vs Client SDK vs CLI.
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Step-by-step walkthrough building a bug-fixing agent in Python or TypeScript.
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Turns, message types, tool execution, permission modes, effort, context window, auto-compaction, and `ResultMessage` handling.
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — Enabling CLAUDE.md, skills, slash commands, and filesystem hooks via `settingSources`.
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage per step, deduplicating parallel tool calls, cumulative cost, per-model breakdown, and caveats on client-side estimates.
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — Defining tools with `@tool` / `tool()`, in-process MCP servers, annotations, error handling, images and resources.
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and restore file state across agent runs.
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Callback-based interception: `PreToolUse`, `PostToolUse`, `Stop`, `PreCompact`, and more; matchers, decisions, and output shapes.
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Deploying agents to Docker, cloud runtimes, and CI/CD.
- [MCP](references/claude-code-agent-sdk-mcp.md) — Connecting stdio, SSE, HTTP, and SDK MCP servers; tool search for on-demand loading.
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from the old Claude Code SDK to the Claude Agent SDK.
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — CLAUDE.md, `append`, and fully custom prompts; output styles.
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, tracing, and monitoring agent runs.
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Allow/deny rules, permission modes, rule syntax like `Bash(npm:*)`, and the evaluation pipeline.
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading plugin bundles programmatically into the SDK.
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — Full Python API: `query`, `ClaudeSDKClient`, `ClaudeAgentOptions`, message types, `@tool`, `HookMatcher`, `AgentDefinition`.
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Sandboxing, secret hygiene, and hardening production agents.
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Resume, continue, and fork patterns; capturing and persisting session IDs.
- [Skills](references/claude-code-agent-sdk-skills.md) — Loading Agent Skills into an SDK session.
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — Invoking built-in and project slash commands programmatically; `/compact`, `/clear`, and more.
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — Enabling partial messages and consuming `StreamEvent` deltas.
- [Streaming vs single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Choosing between persistent streaming input and one-shot single messages.
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — Constraining final results to a schema with validation and retry limits.
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Programmatic `AgentDefinition`, filesystem subagents, inheritance rules, and `parent_tool_use_id`.
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — Using the `TodoWrite` tool and consuming todo updates from the stream.
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Dynamically discovering and loading tools via `ToolSearch` to reduce context.
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — Full TypeScript API: `query`, `Options`, message interfaces, `tool()`, `createSdkMcpServer`, hook types.
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Preview of upcoming TypeScript API changes.
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` approval callback and `AskUserQuestion` for interactive flows.

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
- Streaming vs single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
