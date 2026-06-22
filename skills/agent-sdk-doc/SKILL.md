---
name: agent-sdk-doc
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the Python and TypeScript library that lets you embed Claude Code's autonomous agent loop in your own applications.

## Quick Reference

### Installation

| Language | Package | Requirement |
| :--- | :--- | :--- |
| TypeScript | `npm install @anthropic-ai/claude-agent-sdk` | Node.js 18+; bundles the Claude binary |
| Python | `pip install claude-agent-sdk` | Python 3.10+ |

### Authentication

| Provider | Environment variable(s) |
| :--- | :--- |
| Anthropic API (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Entry Points

| Interface | Python | TypeScript | Best for |
| :--- | :--- | :--- | :--- |
| One-off query | `query()` async generator | `query()` async generator | Single tasks, automation scripts |
| Multi-turn session | `ClaudeSDKClient` (async context manager) | `query()` with `continue: true` | Conversations, follow-ups |
| Pre-warm subprocess | — | `startup()` returns `WarmQuery` | Low-latency first call |

### Built-in Tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| File ops | `Read`, `Edit`, `Write` | Read, modify, and create files |
| Search | `Glob`, `Grep` | Find files by pattern, search content with regex |
| Execution | `Bash` | Run shell commands, scripts, git operations |
| Web | `WebSearch`, `WebFetch` | Search the web, fetch and parse pages |
| Discovery | `ToolSearch` | Dynamically load MCP tool schemas on demand |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TaskCreate`, `TaskUpdate` | Spawn subagents, invoke skills, ask the user, track tasks |
| Monitoring | `Monitor` | Watch a background script, react to each output line |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Unlisted tools call `canUseTool` callback; no callback = deny | Interactive apps with custom approval UI |
| `acceptEdits` | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`); other Bash falls through | Trusted dev workflows |
| `plan` | Claude can read/explore but not edit source files | Planning and analysis only |
| `dontAsk` | Never prompts; anything not pre-approved is denied | Locked-down headless agents |
| `auto` (TypeScript only) | Model classifier approves or denies each tool call | Autonomous agents with safety guardrails |
| `bypassPermissions` | Runs all tools without prompting; explicit `ask` rules still prompt; cannot run as root | CI, containers, fully isolated environments |

### Permission Evaluation Order

1. Hooks (can allow or deny outright)
2. Deny rules (`disallowedTools` / `disallowed_tools`)
3. Ask rules (from `settings.json`)
4. Permission mode
5. Allow rules (`allowedTools` / `allowed_tools`)
6. `canUseTool` callback (skipped in `dontAsk` mode)

### Allow and Deny Rule Behavior

| Rule | Effect |
| :--- | :--- |
| `allowedTools: ["Read", "Grep"]` | Auto-approve these tools; others still available, fall through to mode |
| `disallowedTools: ["Bash"]` | Remove `Bash` from Claude's context entirely |
| `disallowedTools: ["Bash(rm *)"]` | Keep `Bash` available; deny calls matching `rm *` in every mode including `bypassPermissions` |
| `disallowedTools: ["*"]` | Remove all tools from context |
| `allowedTools: ["mcp__server__*"]` | Allow every tool from a named MCP server |

### Message Types

| Type | Python class | TS `type` field | When emitted |
| :--- | :--- | :--- | :--- |
| Session init | `SystemMessage` (subtype `"init"`) | `"system"` subtype `"init"` | First message; carries `session_id` |
| Claude response | `AssistantMessage` | `"assistant"` | After each model response (TS: content at `.message.content`) |
| Tool results | `UserMessage` | `"user"` | After tool execution |
| Streaming chunk | `StreamEvent` | `"stream_event"` | Only when `includePartialMessages: true` |
| Final result | `ResultMessage` | `"result"` | End of loop; check `subtype` first |
| Compaction marker | `SystemMessage` (subtype `"compact_boundary"`) | `"system"` subtype `"compact_boundary"` | After automatic context compaction |

### ResultMessage Subtypes

| Subtype | Meaning | `result` field present? |
| :--- | :--- | :--- |
| `success` | Task completed normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API error or cancellation interrupted the loop | No |
| `error_max_structured_output_retries` | No valid structured output within retry limit | No |

All subtypes carry `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Key Options (Python: `ClaudeAgentOptions`, TypeScript: `Options`)

| Option (Python / TypeScript) | Default | Description |
| :--- | :--- | :--- |
| `allowed_tools` / `allowedTools` | `[]` | Auto-approve listed tools |
| `disallowed_tools` / `disallowedTools` | `[]` | Block listed tools or patterns |
| `permission_mode` / `permissionMode` | `"default"` | How unapproved tools are handled |
| `max_turns` / `maxTurns` | No limit | Maximum tool-use round trips |
| `max_budget_usd` / `maxBudgetUsd` | No limit | Stop when cost estimate reaches this USD value |
| `effort` | Model default | `"low"` / `"medium"` / `"high"` / `"xhigh"` / `"max"` |
| `model` | CLI default | Model ID or alias |
| `system_prompt` / `systemPrompt` | Minimal | String or preset object |
| `setting_sources` / `settingSources` | All sources | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `resume` | — | Session ID to resume |
| `continue_conversation` / `continue` | `false` | Resume most recent session in cwd |
| `fork_session` / `forkSession` | `false` | Fork instead of continuing on resume |
| `mcp_servers` / `mcpServers` | `{}` | External MCP server configs |
| `hooks` | — | Programmatic hook callbacks |
| `agents` | — | Programmatic subagent definitions |
| `cwd` | `process.cwd()` | Working directory |
| `include_partial_messages` / `includePartialMessages` | `false` | Emit streaming `StreamEvent` messages |
| `plugins` | `[]` | Load local plugin directories |
| `session_store` / `sessionStore` | — | External storage adapter for cross-host resume |
| `enable_file_checkpointing` / `enableFileCheckpointing` | `false` | Track file changes for rewind |
| `persist_session` / `persistSession` | `true` | Write session JSONL to disk (TypeScript only) |
| `thinking` | `"adaptive"` on supported models | `ThinkingConfig` controlling extended thinking |
| `skills` | — | Skill names to enable, or `"all"` |
| `output_format` / `outputFormat` | — | JSON Schema for structured output |
| `can_use_tool` / `canUseTool` | — | Runtime tool approval callback |

### Session Management

| Goal | Python | TypeScript |
| :--- | :--- | :--- |
| New session | `query()` (default) | `query()` (default) |
| Continue most recent | `continue_conversation=True` | `continue: true` |
| Resume specific session | `resume=session_id` | `resume: sessionId` |
| Fork session | `resume=id, fork_session=True` | `resume: id, forkSession: true` |
| Multi-turn in one process | `ClaudeSDKClient` (automatic) | `continue: true` on each call |
| Session metadata | `list_sessions()`, `get_session_info()`, `rename_session()`, `tag_session()` | `listSessions()`, `getSessionInfo()`, `renameSession()`, `tagSession()` |

Session files are stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. For cross-host resume, use a `SessionStore` adapter or move the JSONL file.

### Hooks (Programmatic Callbacks)

Registered under `hooks` (TypeScript) or `hooks` dict (Python). Key hook events:

| Event | When it fires | Common uses |
| :--- | :--- | :--- |
| `PreToolUse` | Before a tool executes | Validate inputs, block dangerous commands |
| `PostToolUse` | After a tool returns | Audit outputs, trigger side effects |
| `UserPromptSubmit` | When a prompt is sent | Inject additional context |
| `Stop` | When the agent finishes | Validate result, save state |
| `SubagentStart` / `SubagentStop` | When a subagent spawns or completes | Track parallel tasks |
| `PreCompact` | Before context compaction | Archive transcript |
| `SessionStart` / `SessionEnd` | Session lifecycle (TypeScript only) | Resource setup/teardown |

Hook callback returns `{}` to allow, or a `hookSpecificOutput` with `permissionDecision: "deny"` and `permissionDecisionReason` to block. The top-level `decision` / `reason` pattern is deprecated for `PreToolUse`.

Python matchers use `HookMatcher(matcher="Write|Edit", hooks=[callback])`. TypeScript uses `{ matcher: "Write|Edit", hooks: [callback] }`.

### Subagents (`AgentDefinition`)

| Field | Required | Description |
| :--- | :--- | :--- |
| `description` | Yes | When Claude should delegate to this agent |
| `prompt` | Yes | The agent's system prompt |
| `tools` | No | Allowed tools (inherits parent tools if omitted) |
| `disallowedTools` | No | Tools to remove |
| `model` | No | Model alias or ID; `"inherit"` to use parent model |
| `skills` | No | Skill names to preload |
| `maxTurns` | No | Turn limit for this subagent |
| `background` | No | Run as non-blocking background task |
| `effort` | No | Effort level override |
| `permissionMode` | No | Permission mode for this subagent |
| `memory` | No | `"user"`, `"project"`, or `"local"` |

Include `"Agent"` in `allowedTools` to auto-approve subagent invocations. Subagents start with a fresh conversation; only their final message returns to the parent as a tool result.

### MCP Server Config Types

| Transport | Python | TypeScript | Key fields |
| :--- | :--- | :--- | :--- |
| stdio (subprocess) | `McpStdioServerConfig` | `McpStdioServerConfig` | `command`, `args`, `env` |
| SSE | `McpSSEServerConfig` | `McpSSEServerConfig` | `type: "sse"`, `url`, `headers` |
| HTTP | `McpHttpServerConfig` | `McpHttpServerConfig` | `type: "http"`, `url`, `headers` |
| In-process SDK server | `McpSdkServerConfig` (via `create_sdk_mcp_server`) | `McpSdkServerConfigWithInstance` (via `createSdkMcpServer`) | `type: "sdk"`, `name`, `instance` |

MCP tools are auto-approved with `mcp__<server>__<tool>` names. Use `mcp__<server>__*` to allow all tools from a server.

### Custom Tools (In-process MCP Server)

Python: use the `@tool` decorator, then `create_sdk_mcp_server(name, tools=[...])`.
TypeScript: use `tool(name, description, zodSchema, handler)`, then `createSdkMcpServer({ name, tools: [...] })`.

Tool handlers return `{ content: [...], isError?: bool, structuredContent?: object }`. Set `readOnlyHint: true` on annotations to allow parallel execution.

### `settingSources` — What Each Source Loads

| Source | Location | What it loads |
| :--- | :--- | :--- |
| `"project"` | `<cwd>/.claude/` and parent dirs | `CLAUDE.md`, `rules/*.md`, project skills, hooks, `settings.json` |
| `"user"` | `~/.claude/` | User `CLAUDE.md`, `rules/*.md`, user skills, `settings.json` |
| `"local"` | `<cwd>/.claude/settings.local.json` + parent `CLAUDE.local.md` | Local settings and local memory |

Always loaded regardless of `settingSources`: managed policy settings, `~/.claude.json`, auto memory at `~/.claude/projects/`. For multi-tenant isolation, set `settingSources: []` and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

### Effort Levels

| Level | Behavior | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal reasoning | File lookups, listing directories |
| `"medium"` | Balanced | Routine edits, standard tasks |
| `"high"` | Thorough analysis | Refactors, debugging |
| `"xhigh"` | Extended reasoning depth | Recommended on Fable 5 and Opus 4.7+ |
| `"max"` | Maximum reasoning | Multi-step problems requiring deep analysis |

### Cost Tracking

`total_cost_usd` / `totalCostUsd` on `ResultMessage` is a client-side estimate — not authoritative billing data. For billing, use the Usage and Cost API or the Claude Console. Track per-step usage from `AssistantMessage.usage`; per-model breakdown from `ResultMessage.modelUsage` / `model_usage`.

### Context Management Tips

- Each subagent gets a fresh context (no parent turns); only its final message goes to the parent.
- Automatic compaction fires when context approaches the limit; a `compact_boundary` system message is emitted.
- Use `CLAUDE.md` (via `settingSources`) for persistent instructions that survive compaction.
- MCP tool search (`ToolSearch`) defers tool schemas until needed, reducing baseline context.
- Lower `effort` for routine tasks to reduce tokens and cost.

### Hosting / Deployment Patterns

- Every `query()` call spawns a `claude` CLI subprocess; N concurrent sessions = N subprocesses.
- Pass `cwd` per session to isolate working directories.
- Session JSONL files live on local disk; they don't survive container restarts without `SessionStore`.
- Use `SessionStore` adapter to mirror transcripts to external storage for cross-host resume.
- For Bun single-file compilations, use `extractFromBunfs()` to resolve the bundled CLI binary path.

### Secure Deployment Checklist

- Apply `permissionMode: "bypassPermissions"` only in isolated containers or CI.
- Use `disallowedTools` or scoped deny rules (e.g., `"Bash(rm *)"`) to block dangerous patterns.
- Set `settingSources: []` and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` for multi-tenant isolation.
- Prefer proxies for credentials rather than injecting API keys directly into the agent environment.
- Leverage `PreToolUse` hooks to validate or block tool calls before execution.

### Streaming vs. Single Message Input

| Mode | Default | Supports images | Supports mid-session interrupts | Supports queued messages |
| :--- | :--- | :--- | :--- | :--- |
| Single message (string `prompt`) | Yes | No | No | No |
| Streaming input (async generator `prompt`) | No | Yes | Yes | Yes |

Pass an `AsyncGenerator<SDKUserMessage>` as `prompt` to enter streaming input mode. Python uses `ClaudeSDKClient.query(generator)`.

### TypeScript-Only Features

- `startup()` / `WarmQuery` — pre-warm subprocess to eliminate first-call latency
- `applyFlagSettings()` — change settings on a running session without restart
- `setPermissionMode()`, `setModel()` — mid-session changes (streaming input mode only)
- `persistSession: false` — in-memory only session
- `permissionMode: "auto"` — model classifier for tool approval
- `Query.interrupt()`, `Query.setMcpServers()`, `Query.reconnectMcpServer()` — live session control
- `resolveSettings()` — inspect effective merged settings without spawning a session

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK overview, capabilities, comparison to Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — Build a bug-fixing agent in minutes; tools and permission modes intro
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — Turn lifecycle, message types, context window, compaction, result handling
- [Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, hooks from filesystem
- [Sessions](references/claude-code-agent-sdk-sessions.md) — Continue, resume, fork; `ClaudeSDKClient` vs `query()`; cross-host resume
- [Streaming vs. single mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — When to use streaming input vs. string prompts; image support
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — Real-time token streaming with `includePartialMessages`
- [Permissions](references/claude-code-agent-sdk-permissions.md) — Permission evaluation order, allow/deny rules, permission modes
- [Hooks](references/claude-code-agent-sdk-hooks.md) — Programmatic hook callbacks, available events, matchers, outputs
- [Subagents](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, context isolation, parallelization, what subagents inherit
- [MCP](references/claude-code-agent-sdk-mcp.md) — Transport types, tool search, authentication, error handling
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — In-process MCP server, `@tool` / `tool()`, annotations, images, structured data
- [Skills](references/claude-code-agent-sdk-skills.md) — Filesystem skills in the SDK, `skills` option
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — Using slash commands (e.g., `/compact`) as SDK prompts
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, interactive approval flows
- [System prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — Custom prompts, preset, append, prompt-cache optimization
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema output format, validation, retries
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — Token usage, `total_cost_usd` caveats, per-step and per-model breakdown
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — Snapshot and revert file changes within a session
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — `SessionStore` interface for cross-host session persistence
- [Observability](references/claude-code-agent-sdk-observability.md) — Logging, debug output, hook events in the message stream
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — Task creation and tracking with `TaskCreate` / `TaskUpdate`
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — Deferred MCP tool schema loading via `ToolSearch`
- [Plugins](references/claude-code-agent-sdk-plugins.md) — Loading local plugins via `plugins` option
- [Hosting](references/claude-code-agent-sdk-hosting.md) — Subprocess model, session patterns, Docker/Kubernetes, multi-tenant isolation
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — Threat model, permissions, sandboxing, credential management, network controls
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — Upgrading from older SDK versions
- [TypeScript reference](references/claude-code-agent-sdk-typescript.md) — Complete TypeScript API: `query()`, `startup()`, `tool()`, `Options`, all message types, hook types
- [Python reference](references/claude-code-agent-sdk-python.md) — Complete Python API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — Notes on removed/deprecated v2 session API

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Streaming vs. single mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- System prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- Plugins: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- TypeScript reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Python reference: https://code.claude.com/docs/en/agent-sdk/python.md
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
