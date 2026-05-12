---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — building autonomous AI agents in Python and TypeScript with built-in tools, hooks, sessions, MCP, subagents, permissions, streaming, structured outputs, custom tools, hosting, observability, and cost tracking.
user-invocable: false
---

# Claude Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

### Installation

| Language   | Package                            | Install command                            |
| :--------- | :--------------------------------- | :----------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`   | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                 | `pip install claude-agent-sdk`             |

Set `ANTHROPIC_API_KEY` before running. The TypeScript SDK bundles a native Claude Code binary — no separate CLI install needed.

### Core API

**Python:**
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async for message in query(
    prompt="Find and fix the bug in auth.py",
    options=ClaudeAgentOptions(allowed_tools=["Read", "Edit", "Bash"]),
):
    print(message)
```

**TypeScript:**
```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "Find and fix the bug in auth.ts",
  options: { allowedTools: ["Read", "Edit", "Bash"] }
})) {
  console.log(message);
}
```

### Built-in Tools

| Tool             | What it does                                              |
| :--------------- | :-------------------------------------------------------- |
| `Read`           | Read files in the working directory                       |
| `Write`          | Create new files                                          |
| `Edit`           | Make precise edits to existing files                      |
| `Bash`           | Run shell commands, scripts, git operations               |
| `Monitor`        | Watch a background script, react to each output line      |
| `Glob`           | Find files by pattern (`**/*.ts`, `src/**/*.py`)          |
| `Grep`           | Search file contents with regex                           |
| `WebSearch`      | Search the web for current information                    |
| `WebFetch`       | Fetch and parse web page content                          |
| `AskUserQuestion`| Ask the user a clarifying question with multiple choice   |
| `ToolSearch`     | Dynamically find and load tools on demand                 |
| `Agent`          | Spawn subagents for focused subtasks                      |
| `Skill`          | Invoke a defined skill                                    |
| `TodoWrite`      | Track tasks during execution                              |

### ClaudeAgentOptions / Options — Key Fields

| Option (Python / TypeScript)                         | Description                                              |
| :--------------------------------------------------- | :------------------------------------------------------- |
| `allowed_tools` / `allowedTools`                     | Auto-approve listed tools (no permission prompt)         |
| `disallowed_tools` / `disallowedTools`               | Always deny listed tools                                 |
| `permission_mode` / `permissionMode`                 | Global permission behavior (see Permission Modes)        |
| `system_prompt` / `systemPrompt`                     | Custom system prompt                                     |
| `mcp_servers` / `mcpServers`                         | MCP server configurations                                |
| `agents`                                             | Named subagent definitions                               |
| `hooks`                                              | Callback hooks for lifecycle events                      |
| `max_turns` / `maxTurns`                             | Maximum tool-use round trips                             |
| `max_budget_usd` / `maxBudgetUsd`                    | Cost cap before stopping                                 |
| `effort`                                             | Reasoning depth: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `model`                                              | Override model (e.g., `"claude-sonnet-4-6"`)             |
| `resume`                                             | Resume a session by ID                                   |
| `fork_session` / `forkSession`                       | Fork the resumed session                                 |
| `continue_conversation` / `continue`                 | Resume the most recent session in the current directory  |
| `setting_sources` / `settingSources`                 | Which filesystem settings to load (`"user"`, `"project"`, `"local"`) |
| `output_format` / `outputFormat`                     | JSON Schema for structured output                        |
| `include_partial_messages` / `includePartialMessages`| Enable real-time streaming of text and tool call deltas  |

### Permission Modes

| Mode                  | Behavior                                                                                   |
| :-------------------- | :----------------------------------------------------------------------------------------- |
| `"default"`           | Unmatched tools trigger `canUseTool` callback; no callback = deny                          |
| `"acceptEdits"`       | Auto-approves file edits and common filesystem commands (`mkdir`, `touch`, `mv`, `cp`, etc.) |
| `"plan"`              | Read-only tools only; Claude explores and plans without editing files                      |
| `"dontAsk"`           | Anything not pre-approved by allow rules is denied; never prompts                          |
| `"auto"` (TS only)    | Model classifier approves or denies each tool call                                         |
| `"bypassPermissions"` | All tools run without prompts; use only in isolated/sandboxed environments                 |

**Permission evaluation order:** Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

### Message Types

| Message Type       | Python class       | TypeScript `type` field | When emitted                                      |
| :----------------- | :----------------- | :---------------------- | :------------------------------------------------ |
| System init        | `SystemMessage`    | `"system"` + `"init"`   | First message; contains `session_id`, tools, MCP  |
| Assistant response | `AssistantMessage` | `"assistant"`           | After each Claude turn (text + tool calls)        |
| Tool result        | `UserMessage`      | `"user"`                | After each tool execution with results            |
| Stream delta       | `StreamEvent`      | `"stream_event"`        | Real-time token chunks (requires `includePartialMessages`) |
| Final result       | `ResultMessage`    | `"result"`              | End of loop; contains `result`, cost, `session_id` |

### ResultMessage Subtypes

| Subtype                               | Meaning                                          | `result` field? |
| :------------------------------------ | :----------------------------------------------- | :-------------: |
| `success`                             | Task completed normally                          | Yes             |
| `error_max_turns`                     | Hit `maxTurns` limit                             | No              |
| `error_max_budget_usd`                | Hit `maxBudgetUsd` limit                         | No              |
| `error_during_execution`              | API failure or cancelled request                 | No              |
| `error_max_structured_output_retries` | Structured output validation failed              | No              |

All subtypes include `total_cost_usd`, `usage`, `num_turns`, and `session_id`.

### Sessions

| Pattern                          | How                                                                 |
| :------------------------------- | :------------------------------------------------------------------ |
| One-shot task                    | Single `query()` call, no session options needed                    |
| Multi-turn (Python)              | Use `ClaudeSDKClient`; session ID tracked automatically             |
| Multi-turn (TypeScript)          | Pass `continue: true` on subsequent `query()` calls                 |
| Resume by ID                     | Pass `resume: sessionId` to `query()`                               |
| Fork a session                   | Pass `resume: sessionId` + `forkSession: true`                      |
| Stateless (TS only)              | Set `persistSession: false`                                         |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. The `cwd` must match when resuming.

### Hooks — Available Events

| Hook Event         | Python | TypeScript | When it fires                          | Common use                            |
| :----------------- | :-----: | :---------: | :------------------------------------- | :------------------------------------ |
| `PreToolUse`       | Yes    | Yes        | Before a tool executes                 | Block dangerous commands, validate    |
| `PostToolUse`      | Yes    | Yes        | After a tool returns                   | Audit, trigger side effects           |
| `PostToolUseFailure`| Yes   | Yes        | After a tool errors                    | Handle or log tool errors             |
| `PostToolBatch`    | No     | Yes        | After a full batch of tool calls       | Inject conventions once per batch     |
| `UserPromptSubmit` | Yes    | Yes        | When a prompt is sent                  | Inject additional context             |
| `Stop`             | Yes    | Yes        | When agent finishes                    | Save session state                    |
| `SubagentStart`    | Yes    | Yes        | Subagent spawns                        | Track parallel tasks                  |
| `SubagentStop`     | Yes    | Yes        | Subagent completes                     | Aggregate parallel results            |
| `PreCompact`       | Yes    | Yes        | Before context compaction              | Archive full transcript               |
| `PermissionRequest`| Yes    | Yes        | Permission dialog would show           | Custom permission handling            |
| `Notification`     | Yes    | Yes        | Agent status messages                  | Forward to Slack, PagerDuty           |
| `SessionStart`     | No     | Yes        | Session initialization                 | Initialize logging and telemetry      |
| `SessionEnd`       | No     | Yes        | Session termination                    | Clean up temporary resources          |

**Hook output fields:** `hookSpecificOutput.permissionDecision` (`"allow"`, `"deny"`, `"ask"`, `"defer"`), `hookSpecificOutput.updatedInput`, `hookSpecificOutput.additionalContext`, `systemMessage`, `continue` / `continue_`.

**Deny priority:** When multiple hooks run, `deny` wins over `defer`, which wins over `ask`, which wins over `allow`.

### Subagents

Include `Agent` in `allowedTools` for subagent invocation. Define named subagents via the `agents` option:

```python
from claude_agent_sdk import AgentDefinition

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Glob", "Grep", "Agent"],
    agents={
        "code-reviewer": AgentDefinition(
            description="Expert code reviewer. Use for quality and security reviews.",
            prompt="You are a code review specialist...",
            tools=["Read", "Grep", "Glob"],
            model="sonnet",
        )
    },
)
```

**AgentDefinition fields:** `description` (required), `prompt` (required), `tools`, `disallowedTools`, `model`, `skills`, `memory`, `mcpServers`, `maxTurns`, `background`, `effort`, `permissionMode`.

Subagents run in a fresh context window. They receive their system prompt and the Agent tool's prompt string, but not the parent's conversation history.

### MCP Servers

MCP tool names follow: `mcp__{server-name}__{tool-name}`. Always grant permission with `allowedTools`:

```typescript
options: {
  mcpServers: {
    github: { command: "npx", args: ["-y", "@modelcontextprotocol/server-github"], env: { GITHUB_TOKEN: "..." } },
    "remote-api": { type: "http", url: "https://api.example.com/mcp", headers: { Authorization: "Bearer ..." } }
  },
  allowedTools: ["mcp__github__*", "mcp__remote-api__query"]
}
```

**Transport types:** `stdio` (local processes via `command`/`args`), `http` / `sse` (remote servers via `url`), SDK MCP servers (in-process via `createSdkMcpServer`).

### Custom Tools

```typescript
import { tool, createSdkMcpServer } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const myTool = tool(
  "tool_name", "Description Claude reads",
  { input_field: z.string().describe("What it does") },
  async (args) => ({ content: [{ type: "text", text: `Result: ${args.input_field}` }] })
);

const server = createSdkMcpServer({ name: "my-server", version: "1.0.0", tools: [myTool] });
// Pass: mcpServers: { "my-server": server }, allowedTools: ["mcp__my-server__tool_name"]
```

Handler returns `{ content: [...], isError?: true, structuredContent?: {...} }`. Add `readOnlyHint: true` in annotations to enable parallel execution.

### Structured Outputs

```typescript
options: {
  outputFormat: { type: "json_schema", schema: { type: "object", properties: { name: { type: "string" } }, required: ["name"] } }
}
// Access: message.structured_output on ResultMessage with subtype "success"
```

Use Zod (`z.toJSONSchema()`) or Pydantic (`Model.model_json_schema()`) for type-safe schemas.

### Streaming Output

Enable with `includePartialMessages: true`. Check for `StreamEvent` messages (`type === "stream_event"`), then `event.type === "content_block_delta"` with `delta.type === "text_delta"` for text chunks or `delta.type === "input_json_delta"` for streaming tool inputs.

Note: streaming is incompatible with `maxThinkingTokens` (extended thinking) and does not stream structured output.

### Cost Tracking

`ResultMessage` includes `total_cost_usd` (estimated), `usage` dict, and `model_usage` / `modelUsage` per-model breakdown. Deduplicate per-step usage by `message_id` when parallel tool calls share the same ID. Use `ENABLE_PROMPT_CACHING_1H=1` to extend cache TTL from 5 minutes to 1 hour.

### Hosting & Deployment

**Minimum requirements:** 1 GiB RAM, 5 GiB disk, 1 CPU, outbound HTTPS to `api.anthropic.com`.

**Patterns:**
- **Ephemeral:** new container per task, destroy after completion
- **Long-running:** persistent containers for high-frequency or proactive agents
- **Hybrid:** ephemeral containers hydrated with session history
- **Single container:** multiple SDK processes sharing one container (rare)

**Sandbox providers:** Modal, Cloudflare, Daytona, E2B, Fly Machines, Vercel Sandbox.

### Observability (OpenTelemetry)

Set `CLAUDE_CODE_ENABLE_TELEMETRY=1` plus at least one of: `OTEL_METRICS_EXPORTER`, `OTEL_LOGS_EXPORTER`, `OTEL_TRACES_EXPORTER` (traces also require `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1`). Pass via process environment or `options.env` (`...process.env` in TypeScript to avoid replacing inherited env).

### Migration from Claude Code SDK

| Aspect          | Old                            | New                              |
| :-------------- | :----------------------------- | :------------------------------- |
| TS/JS package   | `@anthropic-ai/claude-code`    | `@anthropic-ai/claude-agent-sdk` |
| Python package  | `claude-code-sdk`              | `claude-agent-sdk`               |
| Python imports  | `claude_code_sdk`              | `claude_agent_sdk`               |

All API signatures are unchanged; update package name and imports only.

### settingSources Values

| Value       | What loads                                            |
| :---------- | :---------------------------------------------------- |
| `"user"`    | `~/.claude/` — user CLAUDE.md, skills, hooks, settings |
| `"project"` | `./.claude/` in `cwd` — project CLAUDE.md, skills, hooks, `.mcp.json`, settings |
| `"local"`   | Local overrides (not committed)                       |

Default `query()` loads all three. Pass `settingSources: []` to disable filesystem settings (managed policy and `~/.claude.json` always load regardless).

## Full Documentation

For the complete official documentation, see the reference files:

- [Agent SDK overview](references/claude-code-agent-sdk-overview.md) — what the SDK is, capabilities, built-in tools, comparison with Claude Code CLI, Managed Agents, and Client SDK
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — install, set API key, build a bug-fixing agent, permission modes, troubleshooting
- [How the agent loop works](references/claude-code-agent-sdk-agent-loop.md) — turns, message types, tool execution, context window, compaction, sessions, result handling
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — complete API: `query()`, `startup()`, `tool()`, `Options`, all message types, hook types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — complete API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, all message types, hook types
- [Work with sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork patterns; `ClaudeSDKClient`; cross-host resumption; session listing and tagging
- [Intercept and control agent behavior with hooks](references/claude-code-agent-sdk-hooks.md) — hook events, matchers, callback API, async outputs, common examples
- [Configure permissions](references/claude-code-agent-sdk-permissions.md) — allow/deny rules, permission modes, dynamic mode changes
- [Subagents in the SDK](references/claude-code-agent-sdk-subagents.md) — `AgentDefinition`, context isolation, parallelization, resuming subagents
- [Connect to external tools with MCP](references/claude-code-agent-sdk-mcp.md) — transport types, tool naming, auth, tool search, error handling
- [Give Claude custom tools](references/claude-code-agent-sdk-custom-tools.md) — `tool()` / `@tool`, `createSdkMcpServer`, annotations, error handling, images/resources
- [Stream responses in real-time](references/claude-code-agent-sdk-streaming-output.md) — `includePartialMessages`, `StreamEvent` structure, streaming text and tool calls
- [Streaming vs. single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use streaming vs. collecting all messages at once
- [Get structured output from agents](references/claude-code-agent-sdk-structured-outputs.md) — JSON Schema, Zod/Pydantic, error handling
- [Use Claude Code features in the SDK](references/claude-code-agent-sdk-claude-code-features.md) — `settingSources`, loading CLAUDE.md, skills, hooks, slash commands from filesystem
- [Track cost and usage](references/claude-code-agent-sdk-cost-tracking.md) — per-step usage, per-model breakdown, prompt caching TTL, cross-call accumulation
- [Hosting the Agent SDK](references/claude-code-agent-sdk-hosting.md) — deployment patterns, system requirements, sandbox providers, FAQ
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — network controls, credential management, isolation technologies
- [Observability with OpenTelemetry](references/claude-code-agent-sdk-observability.md) — metrics, log events, traces; OTEL env vars; per-call vs. process-level config
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `systemPrompt`, `appendSystemPrompt`, loading CLAUDE.md memory
- [Handle approvals and user input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, streaming input
- [Skills in the SDK](references/claude-code-agent-sdk-skills.md) — loading project skills, preloading into subagents, `Skill` tool
- [Slash commands in the SDK](references/claude-code-agent-sdk-slash-commands.md) — sending `/compact`, `/clear`, and other commands as prompt strings
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — `TodoWrite` tool behavior and configuration
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — deferring MCP tool schema loading with `ToolSearch`
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshotting and reverting filesystem changes across sessions
- [Plugins in the SDK](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically
- [Migrate to Claude Agent SDK](references/claude-code-agent-sdk-migration-guide.md) — package rename, updated import paths
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — deprecated V2 session API (use V1 `query()` instead)

## Sources

- Agent SDK overview: https://code.claude.com/docs/en/agent-sdk/overview.md
- Quickstart: https://code.claude.com/docs/en/agent-sdk/quickstart.md
- How the agent loop works: https://code.claude.com/docs/en/agent-sdk/agent-loop.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- Python SDK reference: https://code.claude.com/docs/en/agent-sdk/python.md
- Work with sessions: https://code.claude.com/docs/en/agent-sdk/sessions.md
- Intercept and control agent behavior with hooks: https://code.claude.com/docs/en/agent-sdk/hooks.md
- Configure permissions: https://code.claude.com/docs/en/agent-sdk/permissions.md
- Subagents in the SDK: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Connect to external tools with MCP: https://code.claude.com/docs/en/agent-sdk/mcp.md
- Give Claude custom tools: https://code.claude.com/docs/en/agent-sdk/custom-tools.md
- Stream responses in real-time: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs. single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Get structured output from agents: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Use Claude Code features in the SDK: https://code.claude.com/docs/en/agent-sdk/claude-code-features.md
- Track cost and usage: https://code.claude.com/docs/en/agent-sdk/cost-tracking.md
- Hosting the Agent SDK: https://code.claude.com/docs/en/agent-sdk/hosting.md
- Secure deployment: https://code.claude.com/docs/en/agent-sdk/secure-deployment.md
- Observability with OpenTelemetry: https://code.claude.com/docs/en/agent-sdk/observability.md
- Modifying system prompts: https://code.claude.com/docs/en/agent-sdk/modifying-system-prompts.md
- Handle approvals and user input: https://code.claude.com/docs/en/agent-sdk/user-input.md
- Skills in the SDK: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands in the SDK: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- File checkpointing: https://code.claude.com/docs/en/agent-sdk/file-checkpointing.md
- Plugins in the SDK: https://code.claude.com/docs/en/agent-sdk/plugins.md
- Migrate to Claude Agent SDK: https://code.claude.com/docs/en/agent-sdk/migration-guide.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
