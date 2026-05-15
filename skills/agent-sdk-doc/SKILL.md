---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — query() and ClaudeSDKClient APIs, ClaudeAgentOptions/Options, message types (SystemMessage, AssistantMessage, UserMessage, StreamEvent, ResultMessage), permission modes, hooks, sessions (continue/resume/fork), subagents, custom tools, MCP servers, structured outputs, streaming, file checkpointing, observability (OpenTelemetry), cost tracking, system prompts, Claude Code features (settingSources, skills, slash commands, plugins), hosting, secure deployment, Python and TypeScript SDK references, and migration guide.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK.

## Quick Reference

### Installation

| SDK | Package | Install |
| :--- | :--- | :--- |
| TypeScript | `@anthropic-ai/claude-agent-sdk` | `npm install @anthropic-ai/claude-agent-sdk` |
| Python | `claude-agent-sdk` | `pip install claude-agent-sdk` |

TypeScript SDK bundles a native Claude Code binary; no separate Claude Code install needed.

### Core API: `query()`

The primary entry point. Returns an async iterator/generator streaming messages as the agent works.

**Python:**
```python
async for message in query(
    prompt="Fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

**TypeScript:**
```typescript
for await (const message of query({
  prompt: "Fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

### Python: `query()` vs `ClaudeSDKClient`

| Feature | `query()` | `ClaudeSDKClient` |
| :--- | :--- | :--- |
| Session | New session each call | Reuses same session |
| Conversation | Single exchange | Multi-turn in same context |
| Interrupts | Not supported | Supported |
| Continue chat | New session each time | Maintains conversation |
| Best for | One-off tasks | Continuous conversations |

### TypeScript: `startup()` (pre-warming)

Pre-warms the CLI subprocess before a prompt is available, eliminating spawn latency from the first `query()` call:

```typescript
const warm = await startup({ options: { maxTurns: 3 } });
for await (const message of warm.query("What files are here?")) { ... }
```

### Message Types

| Type | When yielded | Key fields |
| :--- | :--- | :--- |
| `SystemMessage` | Session start and compaction | `subtype: "init"` or `"compact_boundary"`, `session_id` (TS: direct; PY: nested in `.data`) |
| `AssistantMessage` | After each Claude response | `.content` (text + tool call blocks); TS: `.message.content` |
| `UserMessage` | After each tool execution | Tool result content |
| `StreamEvent` | Only when `includePartialMessages: true` | `.event` (raw API events, `content_block_delta`) |
| `ResultMessage` | End of agent loop | `.subtype`, `.result`, `.session_id`, `.total_cost_usd`, `.usage`, `.num_turns` |

**Python:** check with `isinstance(message, ResultMessage)`
**TypeScript:** check with `message.type === "result"`

### ResultMessage Subtypes

| Subtype | Meaning | `result` available? |
| :--- | :--- | :--- |
| `success` | Task finished normally | Yes |
| `error_max_turns` | Hit `maxTurns` limit | No |
| `error_max_budget_usd` | Hit `maxBudgetUsd` limit | No |
| `error_during_execution` | API or cancellation error | No |
| `error_max_structured_output_retries` | Structured output validation failed | No |

All subtypes include `total_cost_usd`, `usage`, `num_turns`, `session_id`, and `stop_reason`.

### Built-in Tools

| Category | Tools | What they do |
| :--- | :--- | :--- |
| File ops | `Read`, `Edit`, `Write` | Read, modify, create files |
| Search | `Glob`, `Grep` | Find files by pattern, search content with regex |
| Execution | `Bash` | Run shell commands, scripts, git operations |
| Web | `WebSearch`, `WebFetch` | Search the web, fetch and parse pages |
| Background | `Monitor` | Watch a background script, react to each output line |
| Discovery | `ToolSearch` | Load tools on demand instead of preloading all |
| Orchestration | `Agent`, `Skill`, `AskUserQuestion`, `TodoWrite` | Spawn subagents, invoke skills, ask the user, track tasks |

### ClaudeAgentOptions / Options (Key Fields)

| Option (PY / TS) | Description |
| :--- | :--- |
| `allowed_tools` / `allowedTools` | Pre-approve specific tools (auto-run without prompting) |
| `disallowed_tools` / `disallowedTools` | Always block these tools (overrides all modes) |
| `permission_mode` / `permissionMode` | Global tool permission behavior (see below) |
| `system_prompt` / `systemPrompt` | Custom system prompt string or preset object |
| `mcp_servers` / `mcpServers` | MCP server configurations |
| `agents` | Programmatic subagent definitions |
| `hooks` | SDK callback hooks |
| `max_turns` / `maxTurns` | Max tool-use round trips before stopping |
| `max_budget_usd` / `maxBudgetUsd` | Max cost (USD) before stopping |
| `effort` | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model` | Model ID to use (default: Claude Code default) |
| `cwd` | Working directory for the agent |
| `resume` | Session ID to resume |
| `fork_session` / `forkSession` | Fork session instead of resuming in place |
| `continue_conversation` / `continue` | Resume most recent session in cwd |
| `setting_sources` / `settingSources` | Which filesystem settings to load: `"user"`, `"project"`, `"local"` |
| `skills` | Which skills to enable: skill name list, `"all"`, or `[]` |
| `plugins` | Plugin directories to load: `[{ type: "local", path: "..." }]` |
| `include_partial_messages` / `includePartialMessages` | Enable streaming `StreamEvent` messages |
| `structured_output` / `structuredOutput` | JSON Schema / Zod / Pydantic for typed agent output |
| `can_use_tool` / `canUseTool` | Callback for interactive tool approval |
| `persist_session` / `persistSession` (TS only) | Set `false` for in-memory-only sessions |
| `path_to_claude_code_executable` / `pathToClaudeCodeExecutable` | Path to `claude` binary override |

### Permission Modes

| Mode | Behavior | Use case |
| :--- | :--- | :--- |
| `"default"` | Unlisted tools trigger `canUseTool` callback; no callback = deny | Interactive apps with user approval |
| `"acceptEdits"` | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`); other Bash follows rules | Trusted dev workflows |
| `"plan"` | Read-only tools run; Claude produces a plan without editing files | Safe exploration |
| `"dontAsk"` | Never prompts; only pre-approved tools run, everything else denied | Locked-down headless agents |
| `"auto"` (TS only) | Model classifier approves/denies each call | Autonomous agents with safety guardrails |
| `"bypassPermissions"` | All allowed tools run without asking; cannot use as root | CI/sandboxed environments |

Permission evaluation order: **Hooks → Deny rules → Permission mode → Allow rules → canUseTool callback**

### Tool Permission Rule Syntax

```
"Bash"             # exact tool name
"Bash(npm *)"      # Bash subcommand matching glob
"mcp__github__*"   # all tools from github MCP server
"Edit|Write"       # multiple tools (pipe-separated)
```

### Sessions: Continue / Resume / Fork

| Approach | When to use | How |
| :--- | :--- | :--- |
| Nothing extra | One-shot task | Single `query()` call |
| `continue: true` (TS) / `continue_conversation=True` (PY) | Multi-turn in one process; pick up most recent session | Pass option on each subsequent call |
| `ClaudeSDKClient` (PY) | Multi-turn in one process with automatic session tracking | Use as async context manager |
| `resume=session_id` | Return to a specific past session | Capture `session_id` from `ResultMessage` |
| `fork_session=True` / `forkSession: true` + `resume` | Try alternative without losing original | Fork creates new session ID; original unchanged |

Session files: `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `cwd` must match when resuming.

Session utilities: `list_sessions()` / `listSessions()`, `get_session_messages()` / `getSessionMessages()`, `get_session_info()` / `getSessionInfo()`, `rename_session()` / `renameSession()`, `tag_session()` / `tagSession()`

### Hooks (SDK Callbacks)

Register in `options.hooks` as callback functions (not shell commands — those come from settings files).

**Python:**
```python
async def my_hook(input_data, tool_use_id, context):
    return {}  # or { "hookSpecificOutput": { ... } }

options = ClaudeAgentOptions(hooks={
    "PostToolUse": [HookMatcher(matcher="Edit|Write", hooks=[my_hook])]
})
```

**TypeScript:**
```typescript
const myHook: HookCallback = async (input) => ({});
options = { hooks: { PostToolUse: [{ matcher: "Edit|Write", hooks: [myHook] }] } };
```

| Hook event | When it fires | Can block? |
| :--- | :--- | :--- |
| `PreToolUse` | Before a tool executes | Yes — return `permissionDecision: "deny"` |
| `PostToolUse` | After a tool returns | No — side effects / audit |
| `UserPromptSubmit` | When a prompt is sent | Yes — inject context or block |
| `Stop` | When agent finishes | Yes — validate result |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle | No / Yes |
| `PreCompact` | Before context compaction | Yes — archive transcript |
| `SessionStart` / `SessionEnd` | Session lifecycle | No |

SDK callback hooks run in your process — they don't consume agent context. Settings-file hooks (shell commands) also fire when the corresponding `settingSources` entry is enabled.

### Subagents

Define in `agents` option; include `"Agent"` in `allowedTools`. Claude invokes them based on each agent's `description`.

**Python:** `AgentDefinition(description=..., prompt=..., tools=[...])`
**TypeScript:** `{ description: ..., prompt: ..., tools: [...] }`

Benefits: context isolation (only final result returns to parent), parallelization, specialized instructions, tool restrictions.

### Custom Tools (In-Process MCP)

Define tools with `@tool` decorator (Python) or `tool()` function (TypeScript), wrap in `create_sdk_mcp_server` / `createSdkMcpServer`, pass to `mcpServers` in options.

Tool definition parts: **name**, **description**, **input schema** (Zod in TS, dict or JSON Schema in PY), **handler** (returns `{ content: [...], isError?, structuredContent? }`).

Set `readOnlyHint: true` on annotations to allow parallel execution.

### MCP Server Configuration

```python
# Python
mcp_servers={
    "playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]},
    "claude-code-docs": {"type": "http", "url": "https://code.claude.com/docs/mcp"}
}
```

MCP tool naming: `mcp__<server-name>__<tool-name>`

Allow all tools from a server: `"mcp__claude-code-docs__*"`

MCP tool search defers loading schemas until needed (default for first-party API; upfront on Vertex AI or custom `ANTHROPIC_BASE_URL`).

### System Prompts

| Setting | Use case |
| :--- | :--- |
| Not set | Minimal default — tool calling only, no Claude Code guidelines |
| `{ type: "preset", preset: "claude_code" }` | Full Claude Code prompt (coding guidelines, safety, terminal-friendly output) |
| `{ type: "preset", preset: "claude_code" } + append` | Claude Code preset plus your custom rules appended |
| Custom string | Fully custom — you provide all behavior |

### Context Window and Compaction

Context accumulates across turns: system prompt, CLAUDE.md, tool definitions, conversation history, tool outputs. Content unchanged between turns (system prompt, CLAUDE.md, tool definitions) is automatically prompt-cached.

Auto-compaction fires when context approaches limit — summarizes older history, emits `compact_boundary` system message. Control with:
- Summarization instructions in CLAUDE.md
- `PreCompact` hook to archive transcript before compaction
- Send `/compact` as a prompt string to compact manually

### Effort Levels

| Level | Behavior | Good for |
| :--- | :--- | :--- |
| `"low"` | Minimal reasoning | File lookups, directory listing |
| `"medium"` | Balanced | Routine edits, standard tasks |
| `"high"` | Thorough analysis (TS default) | Refactors, debugging |
| `"xhigh"` | Extended reasoning | Coding/agentic tasks; recommended on Opus 4.7 |
| `"max"` | Maximum depth | Multi-step problems requiring deep analysis |

### Structured Outputs

Pass a JSON Schema, Zod schema (TS), or Pydantic model (PY) as `structured_output` / `structuredOutput`. SDK validates agent output and re-prompts on mismatch (up to retry limit). On failure: `error_max_structured_output_retries` result.

### Streaming Output

Set `include_partial_messages=True` / `includePartialMessages: true`. SDK yields `StreamEvent` messages with `.event` field containing raw API events. Listen for `content_block_delta` events where `delta.type === "text_delta"` for text chunks.

### Streaming vs Single-Turn Mode

Two input modes for `prompt`:
- **String** (default): single prompt, agent runs to completion
- **AsyncIterable** (streaming input): stream messages to the agent mid-session

### File Checkpointing

Enable to track file changes (Write, Edit, NotebookEdit only — not Bash). Checkpoint UUIDs appear in `UserMessage` stream. Call `rewind_files(checkpoint_id)` / `rewindFiles(checkpointId)` to restore files without rewinding the conversation.

### Cost Tracking

`ResultMessage.total_cost_usd` — client-side estimate, not authoritative billing. Use per-step `usage` on `AssistantMessage` for granular tracking. Deduplicate by message ID when Claude uses multiple tools in one turn (all messages share same ID).

For authoritative billing: use the Usage and Cost API or the Claude Console.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus exporter env vars. Telemetry emitted by the CLI child process, not the SDK itself.

| Signal | Enable with |
| :--- | :--- |
| Metrics (tokens, cost, sessions) | `OTEL_METRICS_EXPORTER` |
| Log events (prompts, API calls, tool results) | `OTEL_LOGS_EXPORTER` |
| Traces (spans per interaction, model request, tool call) | `OTEL_TRACES_EXPORTER` + `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1` |

Pass env vars via `ClaudeAgentOptions.env` (PY: merged with inherited env; TS: replaces inherited env — include `...process.env`).

### Claude Code Features (settingSources)

`settingSources` / `setting_sources` controls which filesystem settings load. Default: user + project sources.

| Source | Loads from |
| :--- | :--- |
| `"user"` | `~/.claude/` |
| `"project"` | `./.claude/` in cwd |
| `"local"` | `./.claude/settings.local.json` |
| `[]` | Nothing (programmatic config only) |

Features available via settings sources: CLAUDE.md instructions, skills (`.claude/skills/*/SKILL.md`), agents (`.claude/agents/`), hooks, slash commands, project permissions.

### Hosting Requirements

- Runtime: Python 3.10+ or Node.js 18+; bundled Claude Code binary (no separate install)
- Resources: 1 GiB RAM, 5 GiB disk, 1 CPU (recommended)
- Network: outbound HTTPS to `api.anthropic.com`
- Sandbox providers: Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox

### Secure Deployment

Threat: prompt injection from content the agent processes. Mitigations:
- Permissions system (allow/deny/ask rules, glob patterns)
- `bypassPermissions` only in isolated containers
- Deny rules hold even in `bypassPermissions` mode
- Web search summarization (raw content not passed directly)
- Network controls to block unauthorized outbound requests
- Credential proxies (agent calls proxy, never sees the key)

### Authentication

| Provider | Env vars |
| :--- | :--- |
| Anthropic (default) | `ANTHROPIC_API_KEY` |
| Amazon Bedrock | `CLAUDE_CODE_USE_BEDROCK=1` + AWS credentials |
| Claude Platform on AWS | `CLAUDE_CODE_USE_ANTHROPIC_AWS=1` + `ANTHROPIC_AWS_WORKSPACE_ID` + AWS credentials |
| Google Vertex AI | `CLAUDE_CODE_USE_VERTEX=1` + GCP credentials |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1` + Azure credentials |

### Migration from Claude Code SDK

| Aspect | Old | New |
| :--- | :--- | :--- |
| TS package | `@anthropic-ai/claude-code` | `@anthropic-ai/claude-agent-sdk` |
| Python package | `claude-code-sdk` | `claude-agent-sdk` |
| Import (TS) | `import { query } from "@anthropic-ai/claude-code"` | `import { query } from "@anthropic-ai/claude-agent-sdk"` |
| Import (PY) | `from claude_code_sdk import ...` | `from claude_agent_sdk import ...` |

API is backward compatible — only package names changed.

### Slash Commands in the SDK

Send slash commands as prompt strings: `"/compact"`, `"/context"`, `"/usage"`. Available commands listed in `SystemMessage` with `subtype: "init"` as `slash_commands` array.

### Todo Tracking

SDK auto-creates todos for complex multi-step tasks (3+ actions). Default tool: `TodoWrite`. Task tools (behind `CLAUDE_CODE_ENABLE_TASKS=1`) are a replacement arriving in a future release.

### Plugins in the SDK

Load local plugins via `plugins` option:
```typescript
options: { plugins: [{ type: "local", path: "./my-plugin" }] }
```
Only `type: "local"` is supported. Download marketplace plugins first, then load from local path.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — capabilities, built-in tools, comparison to Client SDK and Managed Agents
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step first agent, key concepts, permission modes table
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, message types, tool execution, context window, compaction, sessions, result handling
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all types and classes
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — `query()`, `startup()`, `tool()`, `Options`, all types and interfaces
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork, automatic management, cross-host, session utilities
- [Hooks](references/claude-code-agent-sdk-hooks.md) — hook events, matchers, callback API, blocking, modifying inputs, SDK hook format
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission evaluation order, allow/deny rules, permission modes, dynamic mode changes
- [Subagents](references/claude-code-agent-sdk-subagents.md) — defining subagents, context isolation, parallelization, what subagents inherit
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool`, in-process MCP server, schemas, error handling, images, structured data
- [MCP servers](references/claude-code-agent-sdk-mcp.md) — transport types, MCP tool search, authentication, error handling
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod, Pydantic, validation and retries
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent`, text delta handling
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — prompt as string vs async iterable
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — minimal default, `claude_code` preset, append, custom string
- [Use Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, CLAUDE.md, skills, agents, hooks, slash commands
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — filesystem-based skills, `skills` option, discovery
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — discovering and dispatching slash commands programmatically
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — loading local plugins, plugin structure
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — tracking file changes, rewinding to a checkpoint
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite`, todo lifecycle, monitoring changes, Task tools migration
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — per-step usage, result cost, deduplication, per-model breakdown
- [Observability](references/claude-code-agent-sdk-observability.md) — OpenTelemetry signals, configuration, span names, attributes
- [Hosting](references/claude-code-agent-sdk-hosting.md) — system requirements, sandbox providers, production deployment patterns
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — threat model, built-in security features, isolation, network controls, credentials
- [User input and approvals](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, permission approvals, `AskUserQuestion`, defer pattern
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — renaming from Claude Code SDK, package and import changes

## Sources

- Overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- MCP servers: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Use Claude Code features: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Cost tracking: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Observability: https://code.claude.com/docs/en/agent-sdk/observability.md
- Hosting: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- User input and approvals: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Migration guide: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
