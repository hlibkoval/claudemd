---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK: building production AI agents with Claude Code as a library, in Python and TypeScript.

## Quick Reference

### Installation

| Language | Package | Requirement |
|:---------|:--------|:------------|
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+ |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

TypeScript bundles a native `claude` binary as an optional dependency — no separate Claude Code install needed.

### Authentication

| Provider | Environment variable(s) |
|:---------|:------------------------|
| Anthropic API (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### The Agent Loop

1. SDK sends prompt + system prompt + tool definitions to Claude
2. Claude evaluates and responds (text and/or tool calls)
3. SDK executes tools; results feed back to Claude
4. Steps 2–3 repeat until Claude produces a text-only response
5. SDK yields a `ResultMessage` with result, cost, usage, session ID

### Built-in Tools

| Category | Tools |
|:---------|:------|
| File operations | `Read`, `Edit`, `Write` |
| Search | `Glob`, `Grep` |
| Execution | `Bash` |
| Web | `WebSearch`, `WebFetch` |
| Discovery | `ToolSearch` |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate` |
| Monitoring | `Monitor` |

### Permission Modes

| Mode | Behavior |
|:-----|:---------|
| `default` | Tools not covered by allow rules trigger `canUseTool` callback; no callback = deny |
| `acceptEdits` | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`) |
| `plan` | Read-only tools run; Claude explores and produces a plan, no file edits |
| `dontAsk` | Never prompts — pre-approved tools run, everything else is denied |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call |
| `bypassPermissions` | Runs all tools without prompting; cannot be used as root; use only in sandboxed CI |

### Permission Evaluation Order

1. **Hooks** — can deny outright or pass on
2. **Deny rules** (`disallowedTools`) — blocks regardless of mode; bare name removes tool from context
3. **Permission mode** — `bypassPermissions` approves everything remaining
4. **Allow rules** (`allowedTools`) — pre-approves listed tools
5. **`canUseTool` callback** — skipped in `dontAsk` mode

### Key Options (Python `ClaudeAgentOptions` / TypeScript `Options`)

| Option | Python | TypeScript | Default | Description |
|:-------|:-------|:-----------|:--------|:------------|
| Prompt | `prompt` | `prompt` | required | Task string |
| Allowed tools | `allowed_tools` | `allowedTools` | `[]` | Auto-approved tools |
| Disallowed tools | `disallowed_tools` | `disallowedTools` | `[]` | Blocked tools |
| Permission mode | `permission_mode` | `permissionMode` | `'default'` | Global permission policy |
| Permission callback | `can_use_tool` | `canUseTool` | — | Runtime approval callback |
| System prompt | `system_prompt` | `systemPrompt` | — | Custom system prompt |
| Max turns | `max_turns` | `maxTurns` | no limit | Cap tool-use round trips |
| Max budget | `max_budget_usd` | `maxBudgetUsd` | no limit | Stop at USD cost threshold |
| Effort | `effort` | `effort` | Python: unset; TS: `'high'` | `low`, `medium`, `high`, `xhigh`, `max` |
| Model | `model` | `model` | CLI default | Model ID to use |
| Resume session | `resume` | `resume` | — | Session ID to resume |
| Continue | `continue_conversation` | `continue` | `false` | Resume most-recent session |
| Fork | `fork_session` | `forkSession` | `false` | Fork instead of continuing |
| MCP servers | `mcp_servers` | `mcpServers` | `{}` | External tool servers |
| Subagents | `agents` | `agents` | — | Programmatic subagent definitions |
| Hooks | `hooks` | `hooks` | `{}` | Event callbacks |
| Setting sources | `setting_sources` | `settingSources` | all | Which filesystem settings to load |
| Plugins | `plugins` | `plugins` | `[]` | Local plugins to load |
| Working directory | `cwd` | `cwd` | `process.cwd()` | Agent's working directory |
| Structured output | `output_format` | `outputFormat` | — | JSON Schema for typed output |
| Partial messages | `include_partial_messages` | `includePartialMessages` | `false` | Enable streaming token output |
| Persist session | — | `persistSession` | `true` | Write session to disk |
| File checkpointing | `enable_file_checkpointing` | `enableFileCheckpointing` | `false` | Track file changes for rewind |
| Skills | `skills` | `skills` | — | Skill names or `'all'` |
| Agents (main) | `agent` | `agent` | — | Agent name for the main thread |

### Effort Levels

| Level | Reasoning | Good for |
|:------|:----------|:---------|
| `low` | Minimal | File lookups, listing directories |
| `medium` | Balanced | Routine edits, standard tasks |
| `high` | Thorough | Refactors, debugging |
| `xhigh` | Extended | Coding and agentic tasks; recommended on Opus 4.7 |
| `max` | Maximum | Multi-step problems requiring deep analysis |

### Message Types

| Type | When | Key fields |
|:-----|:-----|:-----------|
| `SystemMessage` (Python) / `SDKSystemMessage` (TS) | Session start | `subtype: "init"`, `session_id`, `tools`, `model` |
| `AssistantMessage` | After each Claude response | `content` blocks (text + tool calls) |
| `UserMessage` | After each tool execution | Tool result content |
| `StreamEvent` (Python) / `SDKPartialAssistantMessage` (TS) | When `includePartialMessages: true` | Raw API streaming events |
| `ResultMessage` | End of loop | `subtype`, `result`, `total_cost_usd`, `session_id` |

In TypeScript, `compact_boundary` is its own `SDKCompactBoundaryMessage` rather than a subtype.

### ResultMessage Subtypes

| Subtype | Meaning | `result` present? |
|:--------|:--------|:-----------------|
| `success` | Task finished normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API failure or cancelled | No |
| `error_max_structured_output_retries` | Schema validation failed | No |

All result subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Checking Message Types

| SDK | How |
|:----|:----|
| Python | `isinstance(message, ResultMessage)` |
| TypeScript | `message.type === "result"` |

In TypeScript, content blocks are at `message.message.content`, not `message.content`.

### Session Management

| Approach | Python | TypeScript | Use when |
|:---------|:-------|:-----------|:---------|
| Single query | `query()` | `query()` | One-off task |
| Multi-turn in process | `ClaudeSDKClient` | `continue: true` | Ongoing chat, SDK tracks ID |
| Resume most-recent | `continue_conversation=True` | `continue: true` | After process restart |
| Resume by ID | `resume=session_id` | `resume: sessionId` | Specific past session |
| Fork | `fork_session=True` | `forkSession: true` | Branch without losing original |
| Disable persistence | (always persists) | `persistSession: false` | Stateless task |

Capture session ID from `ResultMessage.session_id`. In TypeScript, also available at `SystemMessage.session_id` on the init message.

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
|:--------|:----------|:-----------------|
| Session | New each call (unless `resume`) | Same session reused automatically |
| Interrupts | Not supported | Supported |
| Use case | One-off tasks | Continuous multi-turn conversations |

### Hook Events

| Hook | Fires when | Common uses |
|:-----|:-----------|:------------|
| `PreToolUse` | Before a tool executes | Validate inputs, block dangerous calls |
| `PostToolUse` | After a tool returns | Audit outputs, trigger side effects |
| `PostToolUseFailure` | After a tool fails | Error handling |
| `PostToolBatch` | After all tools in a batch resolve | Batch auditing |
| `UserPromptSubmit` | When a prompt is sent | Inject additional context |
| `Stop` | When the agent finishes | Validate result, save state |
| `SubagentStart` / `SubagentStop` | When a subagent spawns or completes | Track parallel tasks |
| `PreCompact` | Before context compaction | Archive transcript |
| `SessionStart` / `SessionEnd` | Session lifecycle | State management |
| `PermissionRequest` | When a permission is requested | External notifications |

Hook matcher syntax: `"Write|Edit"` (pipe-separated tool names). No matcher = runs for every event of that type.

### Hook Outputs

| Key | Effect |
|:----|:-------|
| `{}` (empty) | Allow |
| `hookSpecificOutput.permissionDecision: "deny"` | Block the tool call |
| `hookSpecificOutput.permissionDecision: "defer"` | Defer for later resume |
| `hookSpecificOutput.additionalContext` | Inject text into Claude's context |

### Subagents

Defined in `agents` option as `AgentDefinition`:

| Field | Required | Description |
|:------|:---------|:------------|
| `description` | Yes | When to use this agent (Claude reads this) |
| `prompt` | Yes | The subagent's system prompt |
| `tools` | No | Allowed tools (inherits parent's if omitted) |
| `disallowedTools` | No | Blocked tools |
| `model` | No | Model override (`'inherit'` to use parent's) |
| `mcpServers` | No | MCP servers for this agent |
| `skills` | No | Skills to preload |
| `maxTurns` | No | Turn cap for this agent |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Reasoning effort level |
| `permissionMode` | No | Permission mode for this agent |

Include `Agent` in `allowedTools` to auto-approve subagent invocations. Each subagent starts with a fresh conversation; only its final response returns to the parent.

### MCP Server Config Types

| Type | Config fields |
|:-----|:-------------|
| `stdio` | `command`, `args?`, `env?` |
| `sse` | `url`, `headers?` |
| `http` | `url`, `headers?` |
| `sdk` | `name`, `instance` (in-process server) |

MCP tool names: `mcp__<server-name>__<tool-name>`. Wildcard: `mcp__my-server__*`.

### Custom Tools (In-Process MCP Server)

Python: `@tool` decorator + `create_sdk_mcp_server()`
TypeScript: `tool()` function + `createSdkMcpServer()`

Pass the server to `mcpServers` in `query()`. Set `readOnlyHint: true` in annotations to allow parallel execution.

### Structured Output

Pass a JSON Schema (or Zod/Pydantic model) as `output_format` / `outputFormat`. Result appears in `ResultMessage.structured_output`. The SDK retries on schema mismatch; failure yields `error_max_structured_output_retries`.

### Cost Tracking

`total_cost_usd` on `ResultMessage` is a **client-side estimate** — do not bill end users from this. Use the Console Usage page or Usage and Cost API for authoritative billing.

- Per-step usage is on each `AssistantMessage` (deduplicate by message ID within a turn)
- Each `query()` call reports its own cost independently even in multi-call sessions

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true` to receive `StreamEvent` messages. Look for `content_block_delta` events with `delta.type === "text_delta"` for incremental text chunks.

### Setting Sources

| Value | Location |
|:------|:---------|
| `user` | `~/.claude/settings.json` |
| `project` | `.claude/settings.json` |
| `local` | `.claude/settings.local.json` |

Pass `settingSources: []` to disable all filesystem settings. Managed policy settings load regardless.

### Observability (OpenTelemetry)

Enable with `CLAUDE_CODE_ENABLE_TELEMETRY=1`. Three independent signals:

| Signal | Enable env var | What it contains |
|:-------|:--------------|:-----------------|
| Metrics | `OTEL_METRICS_EXPORTER` | Token/cost counters |
| Log events | `OTEL_LOGS_EXPORTER` | Per-prompt, tool, API error records |
| Traces | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` | Spans per interaction, model request, tool call |

### Hosting Patterns

| Pattern | Container lifetime | Best for |
|:--------|:-------------------|:---------|
| Ephemeral | Per task | One-off tasks (bug fix, extraction) |
| Persistent | Long-lived | Multi-turn apps, user sessions |
| Pooled | Reused across tasks | High-throughput, fast startup |

`SessionStore` interface mirrors transcripts to external storage for cross-host resume. TypeScript also has `startup()` to pre-warm the subprocess before a prompt is ready.

### Secure Deployment

- **Permissions system**: allow/deny/prompt rules with glob patterns
- **Sandbox mode**: Bash restricted filesystem and network access
- **Least privilege**: mount only needed directories; inject credentials via proxy
- **Defense in depth**: container isolation + network restrictions + filesystem controls
- **Prompt injection risk**: web search results are summarized before entering context

### Migration from Old SDK

| Aspect | Old | New |
|:-------|:----|:----|
| TypeScript package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Import | Same function names (`query`, `tool`, etc.) | Same function names |

### TypeScript-Only Features

- `startup()` — pre-warms subprocess for zero-latency first query
- `auto` permission mode (model classifier)
- `applyFlagSettings()` — change settings mid-session
- `setPermissionMode()`, `setModel()` — runtime setters
- `rewindFiles()` — restore files to state at a past message (requires `enableFileCheckpointing: true`)
- `listSessions()`, `getSessionMessages()`, `getSessionInfo()`, `renameSession()`, `tagSession()`, `resolveSettings()`
- `persistSession: false` — disable disk persistence

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — What the Agent SDK is, capabilities, comparison with Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes, key concepts, permission mode table
- [How the Agent Loop Works](references/claude-code-agent-sdk-agent-loop.md) — Message lifecycle, turn model, context window, compaction, sessions, result handling
- [Python SDK Reference](references/claude-code-agent-sdk-python.md) — Complete API reference: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, message types, `@tool` decorator
- [TypeScript SDK Reference](references/claude-code-agent-sdk-typescript.md) — Complete API reference: `query()`, `startup()`, `tool()`, `Options`, all message types, hook types
- [TypeScript v2 Preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Preview features in the TypeScript SDK
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork patterns; `ClaudeSDKClient` vs `query()`; cross-host resume
- [Session Storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for external transcript backends
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Intercepting agent events: callbacks, matchers, outputs, available events
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Evaluation order, allow/deny rules, permission modes, `canUseTool` callback
- [User Input](references/claude-code-agent-sdk-user-input.md) — Handling approval requests and `AskUserQuestion` in `canUseTool`
- [Subagents](references/claude-code-agent-sdk-subagents.md) — Defining, invoking, and inheriting context in subagents
- [MCP](references/claude-code-agent-sdk-mcp.md) — Transport types, tool naming, tool search, authentication, error handling
- [Custom Tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP server, `@tool` / `tool()`, annotations, error handling, images
- [Streaming Output](references/claude-code-agent-sdk-streaming-output.md) — Enabling partial messages, handling `StreamEvent` / `content_block_delta`
- [Streaming vs Single Mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — Streaming input mode vs single-message queries
- [Structured Outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, retry handling, error cases
- [Cost Tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, per-step usage, deduplication, caveats
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry setup, metrics, log events, traces, OTLP configuration
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns, Docker/Kubernetes, `SessionStore`
- [Secure Deployment](references/claude-code-agent-sdk-secure-deployment.md) — Threat model, built-in features, isolation, least privilege, network controls
- [Claude Code Features](references/claude-code-agent-sdk-claude-code-features.md) — Loading CLAUDE.md, skills, hooks, commands via `settingSources`
- [Skills](references/claude-code-agent-sdk-skills.md) — Using Claude Code skills from the SDK
- [Slash Commands](references/claude-code-agent-sdk-slash-commands.md) — Sending slash commands as prompts (e.g. `/compact`)
- [Modifying System Prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom, preset, and appended system prompts; output styles; prompt caching
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading local plugins via `plugins` option
- [Tool Search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool schema loading with `ToolSearch`
- [Todo Tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TaskCreate`/`TaskUpdate` tools and task progress events
- [File Checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — `enableFileCheckpointing` and `rewindFiles()` (TypeScript)
- [Migration Guide](references/claude-code-agent-sdk-migration-guide.md) — Migrating from `@anthropic-ai/claude-code` / `claude-code-sdk`

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
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
- TypeScript v2 Preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- TypeScript SDK Reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- User Input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Session Storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
