---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building AI agents programmatically in Python and TypeScript. Covers query(), ClaudeAgentOptions, permission modes, hooks, sessions (continue/resume/fork), subagents, MCP servers, custom tools, structured outputs, streaming vs single-turn mode, file checkpointing, session storage, hosting, secure deployment, observability, cost tracking, and full API references for both Python and TypeScript SDKs.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK — the library for building autonomous AI agents with Claude Code as a programmatic library.

## Quick Reference

### What the Agent SDK Is

The Agent SDK lets you run Claude Code's agent loop inside your own application. Install as a Python or TypeScript package, call `query()`, and Claude reads files, runs commands, edits code, and more — handling tool orchestration automatically.

```
Python:     pip install claude-agent-sdk
TypeScript: npm install @anthropic-ai/claude-agent-sdk
```

The TypeScript SDK bundles a native Claude Code binary; no separate CLI install is needed.

### Core Entry Points

| SDK | Primary API | Multi-turn API |
| :--- | :--- | :--- |
| TypeScript | `query({ prompt, options })` → async generator | `query()` with `continue: true` or `resume` |
| Python | `query(prompt=, options=)` → async iterator | `ClaudeSDKClient` (reuses session automatically) |

### Built-in Tools

| Tool | What it does |
| :--- | :--- |
| `Read` | Read any file in the working directory |
| `Write` | Create new files |
| `Edit` | Make precise edits to existing files |
| `Bash` | Run terminal commands, scripts, git operations |
| `Monitor` | Watch a background script and react to output lines |
| `Glob` | Find files by pattern (`**/*.ts`, `src/**/*.py`) |
| `Grep` | Search file contents with regex |
| `WebSearch` | Search the web for current information |
| `WebFetch` | Fetch and parse web page content |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options |
| `Agent` | Spawn a subagent to handle a focused subtask |

### Key Options (TypeScript `Options` / Python `ClaudeAgentOptions`)

| Option (TS / Python) | Default | Description |
| :--- | :--- | :--- |
| `allowedTools` / `allowed_tools` | `[]` | Auto-approve these tools without prompting |
| `disallowedTools` / `disallowed_tools` | `[]` | Remove tools from Claude's context or deny scoped patterns |
| `permissionMode` / `permission_mode` | `'default'` | Global permission behavior (see table below) |
| `systemPrompt` / `system_prompt` | minimal | Custom system prompt string or preset object |
| `maxTurns` / `max_turns` | unlimited | Cap agentic tool-use turns |
| `maxBudgetUsd` / `max_budget_usd` | unlimited | Stop when client-side cost estimate reaches this USD value |
| `mcpServers` / `mcp_servers` | `{}` | MCP server configurations |
| `agents` | `{}` | Programmatic subagent definitions |
| `hooks` | `{}` | Hook callbacks for lifecycle events |
| `resume` | — | Session ID to resume |
| `continue` / `continue_conversation` | `false` | Resume the most recent session in the current directory |
| `forkSession` / `fork_session` | `false` | When resuming, create a new branch instead of continuing |
| `settingSources` / `setting_sources` | all | Which filesystem config sources to load (`"user"`, `"project"`, `"local"`) |
| `cwd` | `process.cwd()` | Working directory for the agent |
| `model` | CLI default | Claude model to use |
| `effort` | `'high'` | Thinking effort: `'low'`, `'medium'`, `'high'`, `'xhigh'`, `'max'` |
| `enableFileCheckpointing` | `false` | Track file changes for rewinding with `rewindFiles()` |
| `outputFormat` / `output_format` | — | Structured output schema (JSON Schema) |
| `skills` | — | Skills available to the session: list of names or `'all'` |
| `plugins` | `[]` | Load plugins from local paths |
| `persistSession` | `true` | When `false`, session stays in memory only (TS only) |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `default` | Calls `canUseTool` callback for each unresolved tool | Custom approval flows |
| `acceptEdits` | Auto-approves file edits and common filesystem commands | Trusted development workflows |
| `dontAsk` | Denies anything not in `allowedTools` | Locked-down headless agents |
| `auto` | Model classifier approves or denies each tool call (TS only) | Autonomous agents with safety guardrails |
| `bypassPermissions` | Runs every tool without prompts | Sandboxed CI, fully trusted environments |
| `plan` | Read-only tools only | Planning phase before execution |

### Permission Evaluation Order

1. **Hooks** — can deny outright or pass through
2. **Deny rules** (`disallowedTools`) — bare names remove tool from context; scoped patterns (`Bash(rm *)`) block matching calls in all modes
3. **Permission mode** — `bypassPermissions` approves all; `acceptEdits` approves file ops
4. **Allow rules** (`allowedTools`) — matched tools are approved
5. **`canUseTool` callback** — called if unresolved; skipped in `dontAsk` mode (tool denied)

### Hook Events

| Event | When it fires |
| :--- | :--- |
| `PreToolUse` | Before a tool call executes (can allow/deny/modify) |
| `PostToolUse` | After a tool call succeeds |
| `PostToolUseFailure` | After a tool call fails |
| `PostToolBatch` | After all tools in a batch have resolved |
| `UserPromptSubmit` | When a user prompt is submitted |
| `SessionStart` | When a session starts or resumes |
| `SessionEnd` | When a session ends |
| `Stop` | When execution is stopping |
| `SubagentStart` / `SubagentStop` | When a subagent starts or stops |
| `PreCompact` | Before context compaction |
| `PermissionRequest` | When a permission request is made |
| `Notification` | On agent notifications |
| `TaskCompleted` | When a background task completes |

Hook callbacks receive `(input, tool_use_id, context)` and return a JSON output object. Use `permissionDecision: "deny"` to block, `permissionDecision: "allow"` to allow, or return `{}` to pass through. Hooks can also inject `additionalContext` into the conversation.

### Sessions: Continue vs Resume vs Fork

| Approach | How it works | Use when |
| :--- | :--- | :--- |
| Single `query()` | Fresh session each call | One-off tasks |
| `ClaudeSDKClient` (Python) / `continue: true` (TS) | SDK tracks session ID automatically | Multi-turn within one process |
| `continue_conversation=True` / `continue: true` | Resumes most recent session in directory | Pick up after process restart |
| `resume="<session-id>"` | Resumes a specific session by ID | Multiple sessions, specific history |
| `forkSession: true` with `resume` | Creates a new branch from the session | Try a different approach without losing original |

### Message Types (Agent Loop Output)

| Type | When emitted |
| :--- | :--- |
| `SystemMessage` (subtype `init`) | First message — session metadata (session_id, tools, model, etc.) |
| `AssistantMessage` | After each Claude response (text + tool call blocks) |
| `UserMessage` | After each tool result sent back to Claude |
| `ResultMessage` | End of loop — final text, cost, usage, subtype (`success` or error) |
| `StreamEvent` | Partial streaming chunks (only when `includePartialMessages: true`) |

`ResultMessage.subtype` values: `success`, `error_max_turns`, `error_during_execution`, `error_max_budget_usd`, `error_max_structured_output_retries`.

### TypeScript-Only Functions

| Function | Description |
| :--- | :--- |
| `startup(options?)` | Pre-warm CLI subprocess to eliminate cold-start latency; returns `WarmQuery` |
| `listSessions(options?)` | List past sessions with metadata |
| `getSessionMessages(sessionId, options?)` | Read transcript of a past session |
| `getSessionInfo(sessionId, options?)` | Get metadata for a single session by ID |
| `renameSession(sessionId, title)` | Set a custom title on a session |
| `tagSession(sessionId, tag)` | Tag a session (pass `null` to clear) |
| `resolveSettings(options?)` | Inspect merged settings without spawning CLI (alpha) |
| `tool(name, desc, schema, handler)` | Create a type-safe MCP tool definition |
| `createSdkMcpServer(options)` | Create an in-process MCP server |

### Python SDK: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New each call (unless `resume`/`continue`) | Reuses same session automatically |
| Interrupts | Not supported | Supported |
| Multi-turn | Manual via `resume`/`continue_conversation` | Automatic |
| Best for | One-off tasks, scripts | Continuous conversations, chat apps |

### Subagents

Define subagents in the `agents` option. Claude invokes them via the `Agent` tool (add `"Agent"` to `allowedTools` to auto-approve invocations):

```python
AgentDefinition(
    description="When to use this agent",   # Required — Claude reads this to decide
    prompt="System prompt for the agent",    # Required
    tools=["Read", "Grep"],                  # Optional — inherits parent tools if omitted
    model="sonnet",                          # Optional — inherits parent model if omitted
    background=False,                        # Optional — run as non-blocking background task
    max_turns=10,                            # Optional
    permission_mode="acceptEdits",           # Optional
)
```

### MCP Server Config

| Transport | Config fields |
| :--- | :--- |
| `stdio` (default) | `command`, `args?`, `env?` |
| `sse` | `type: "sse"`, `url`, `headers?` |
| `http` | `type: "http"`, `url`, `headers?` |
| `sdk` (in-process, TS) | `type: "sdk"`, `name`, `instance` (McpServer) |

MCP tool names use the pattern `mcp__<server-name>__<tool-name>`. Wildcards work in `allowedTools`: `"mcp__myserver__*"`.

### Hosting Requirements

| Requirement | Detail |
| :--- | :--- |
| Runtime | Python 3.10+ or Node.js 18+ |
| Memory | 1 GiB RAM recommended |
| Disk | 5 GiB recommended |
| Network | Outbound HTTPS to `api.anthropic.com` |
| Isolation | Container-based sandboxing recommended for production |

Sandbox providers: Modal, Cloudflare Sandboxes, Daytona, E2B, Fly Machines, Vercel Sandbox.

### Authentication

Set `ANTHROPIC_API_KEY` env var, or use third-party providers:

| Provider | Env var |
| :--- | :--- |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Agent SDK vs Other Claude Tools

| | Agent SDK | Anthropic Client SDK | Managed Agents |
| :--- | :--- | :--- | :--- |
| Tool execution | Built-in | You implement | Anthropic-hosted |
| Runs in | Your process | Your process | Anthropic infrastructure |
| Interface | Python/TS library | Python/TS library | REST API |
| Best for | Local/prod agents on your infra | Custom tool loops | Production without ops overhead |

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities, comparing to Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — build a bug-fixing agent in minutes; permission modes explained
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — complete API: `query()`, `startup()`, `Options`, message types, hook types, MCP config
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — complete API: `query()`, `ClaudeAgentOptions`, `ClaudeSDKClient`, message types
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — how the loop works, turns, message types, compaction, context window
- [Hooks](references/claude-code-agent-sdk-hooks.md) — intercept and control agent behavior; block, log, transform, and require approval
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, evaluation order
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; ClaudeSDKClient; session IDs; cross-host resuming
- [Session storage](references/claude-code-agent-sdk-session-storage.md) — persist sessions to external backends (SessionStore interface)
- [Subagents](references/claude-code-agent-sdk-subagents.md) — define subagents programmatically; context isolation; parallelization
- [MCP](references/claude-code-agent-sdk-mcp.md) — MCP server config, transport types, tool search, authentication
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — define in-process MCP tools with `tool()` and `createSdkMcpServer()`
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion`, handling clarifying questions
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — partial messages, streaming events
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use each input mode
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema output format, `outputFormat` option
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — custom system prompts, preset, output styles, prompt caching
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — skills, commands, CLAUDE.md, plugins via SDK; `settingSources`
- [Skills](references/claude-code-agent-sdk-skills.md) — loading skills in SDK sessions
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — using slash commands in SDK sessions
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically via `plugins` option
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — track file changes, rewind with `rewindFiles()`
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd`, `usage`, `modelUsage`, `maxBudgetUsd`
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, tracing, debugging hooks and tool calls
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — task progress and todo list events
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — ToolSearch for large MCP tool sets
- [Hosting](references/claude-code-agent-sdk-hosting.md) — container requirements, sandbox providers, production patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies
- [TypeScript v2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — upcoming TypeScript SDK v2 changes
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating between SDK versions

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
- Session storage: https://code.claude.com/docs/en/agent-sdk/session-storage.md
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript v2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
