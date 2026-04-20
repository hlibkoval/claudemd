---
name: agent-sdk-doc
description: Complete official documentation for the Claude Agent SDK — Python and TypeScript APIs, query(), sessions, hooks, permissions, subagents, MCP, custom tools, structured outputs, streaming, hosting, observability, and migration.
user-invocable: false
---

# Agent SDK Documentation

This skill provides the complete official documentation for the Claude Agent SDK (formerly Claude Code SDK).

## Quick Reference

The Claude Agent SDK lets you build production AI agents using the same tools, agent loop, and context management that power Claude Code. Available in Python and TypeScript.

### Installation

| Language   | Package                              | Command                                    |
| :--------- | :----------------------------------- | :----------------------------------------- |
| TypeScript | `@anthropic-ai/claude-agent-sdk`     | `npm install @anthropic-ai/claude-agent-sdk` |
| Python     | `claude-agent-sdk`                   | `pip install claude-agent-sdk`             |

TypeScript bundles a native Claude Code binary — no separate Claude Code install needed.

### Authentication

| Provider        | Environment variable           |
| :-------------- | :----------------------------- |
| Anthropic API   | `ANTHROPIC_API_KEY`            |
| Amazon Bedrock  | `CLAUDE_CODE_USE_BEDROCK=1`    |
| Google Vertex   | `CLAUDE_CODE_USE_VERTEX=1`     |
| Microsoft Azure | `CLAUDE_CODE_USE_FOUNDRY=1`    |

### Built-in tools

| Tool              | What it does                                                        |
| :---------------- | :------------------------------------------------------------------ |
| `Read`            | Read files in the working directory                                 |
| `Write`           | Create new files                                                    |
| `Edit`            | Make precise edits to existing files                                |
| `Bash`            | Run terminal commands, scripts, git operations                      |
| `Monitor`         | Watch a background script, react to each output line                |
| `Glob`            | Find files by pattern (`**/*.ts`, `src/**/*.py`)                    |
| `Grep`            | Search file contents with regex                                     |
| `WebSearch`       | Search the web for current information                              |
| `WebFetch`        | Fetch and parse web page content                                    |
| `AskUserQuestion` | Ask the user clarifying questions with multiple-choice options      |
| `Agent`           | Spawn a subagent (must include in `allowedTools` to use subagents)  |

### Python: `query()` vs `ClaudeSDKClient`

| Feature             | `query()`                     | `ClaudeSDKClient`                  |
| :------------------ | :---------------------------- | :--------------------------------- |
| Session             | New session each call         | Reuses same session                |
| Conversation        | Single exchange               | Multiple turns in same context     |
| Streaming input     | Yes                           | Yes                                |
| Interrupts          | No                            | Yes                                |
| Hooks               | Yes                           | Yes                                |
| Continue chat       | No (new session each time)    | Yes                                |
| Use case            | One-off tasks                 | Continuous conversations           |

### Permission modes

| Mode                | Behavior                                                            | Use case                            |
| :------------------ | :------------------------------------------------------------------ | :---------------------------------- |
| `acceptEdits`       | Auto-approves file edits and common filesystem commands             | Trusted development workflows       |
| `dontAsk`           | Denies anything not in `allowedTools`                               | Locked-down headless agents         |
| `auto`              | Model classifier approves or denies each tool call (TypeScript)     | Autonomous agents with guardrails   |
| `bypassPermissions` | Runs every tool without prompts                                     | Sandboxed CI, fully trusted envs    |
| `default`           | Requires a `canUseTool` callback to handle approval                 | Custom approval flows               |

Permission evaluation order: Hooks → Deny rules → Permission mode → Allow rules → `canUseTool` callback.

`disallowed_tools` always blocks even in `bypassPermissions` mode. `allowed_tools` does not constrain `bypassPermissions`.

### Sessions

| Goal                                          | How                                                              |
| :-------------------------------------------- | :--------------------------------------------------------------- |
| Multi-turn in one process (Python)            | `ClaudeSDKClient` — tracks session ID internally                 |
| Multi-turn in one process (TypeScript)        | `continue: true` on each subsequent `query()` call              |
| Resume most recent session after restart      | `continue_conversation=True` (Py) / `continue: true` (TS)        |
| Resume a specific past session                | Capture `session_id` from `ResultMessage`, pass to `resume`     |
| Branch without losing original               | `fork_session=True` (Py) / `forkSession: true` (TS)             |
| Stateless, no disk write (TypeScript only)    | `persistSession: false`                                          |

Session files stored at `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`. `cwd` must match when resuming.

### Hooks (SDK callbacks)

SDK hooks are callback functions (not shell commands). Configure in `options.hooks`.

| Hook Event           | Python | TypeScript | Trigger                                  |
| :------------------- | :----: | :--------: | :--------------------------------------- |
| `PreToolUse`         | Yes    | Yes        | Before tool call (can block or modify)   |
| `PostToolUse`        | Yes    | Yes        | After tool execution result              |
| `PostToolUseFailure` | Yes    | Yes        | After tool execution failure             |
| `UserPromptSubmit`   | Yes    | Yes        | User prompt submission                   |
| `Stop`               | Yes    | Yes        | Agent execution stop                     |
| `SubagentStart`      | Yes    | Yes        | Subagent initialization                  |
| `SubagentStop`       | Yes    | Yes        | Subagent completion                      |
| `PreCompact`         | Yes    | Yes        | Conversation compaction request          |
| `PermissionRequest`  | Yes    | Yes        | Permission dialog would be displayed     |
| `Notification`       | Yes    | Yes        | Agent status messages                    |
| `SessionStart`       | No     | Yes        | Session initialization                   |
| `SessionEnd`         | No     | Yes        | Session termination                      |
| `Setup`              | No     | Yes        | Session setup/maintenance                |
| `TeammateIdle`       | No     | Yes        | Teammate becomes idle                    |
| `TaskCompleted`      | No     | Yes        | Background task completes                |
| `ConfigChange`       | No     | Yes        | Configuration file changes               |
| `WorktreeCreate`     | No     | Yes        | Git worktree created                     |
| `WorktreeRemove`     | No     | Yes        | Git worktree removed                     |

Hook callback signature: `(input_data, tool_use_id, context) -> dict`. Return `{}` to allow; use `hookSpecificOutput.permissionDecision` (`"allow"/"deny"/"ask"`) for PreToolUse. `deny` takes priority over `ask` over `allow` across all hooks.

Matcher pattern (regex) filters against tool name for tool hooks. MCP tools: `mcp__<server>__<action>`.

Async hooks: return `{"async": True, "asyncTimeout": 30000}` to proceed without waiting.

### Subagents

Include `"Agent"` in `allowedTools`. Define custom agents via `agents` option:

```python
AgentDefinition(description="...", prompt="...", tools=["Read", "Glob"])
```

Messages from within a subagent include `parent_tool_use_id`.

### MCP servers

Configure via `mcp_servers` (Python) / `mcpServers` (TypeScript):

```python
mcp_servers={"playwright": {"command": "npx", "args": ["@playwright/mcp@latest"]}}
```

### Streaming vs single-turn

| Mode                   | Supports images | Hooks | Interrupts | Use case              |
| :--------------------- | :-------------- | :---- | :--------- | :-------------------- |
| Streaming (default)    | Yes             | Yes   | Yes        | Interactive sessions  |
| Single message         | No              | No    | No         | One-shot, stateless   |

Pass an `AsyncGenerator` as `prompt` to use streaming input mode.

### TypeScript `startup()` — pre-warm

Call `startup()` at app boot to pay subprocess spawn cost upfront, then call `.query()` on the returned `WarmQuery` handle when a prompt is ready.

### TypeScript V2 preview

A simplified `send()` / `stream()` interface via `createSession()` is available as an unstable preview. V2 APIs may change; stable docs use V1 `query()`.

### Claude Code filesystem features loaded by SDK

| Feature       | Location                           |
| :------------ | :--------------------------------- |
| Skills        | `.claude/skills/*/SKILL.md`        |
| Slash commands | `.claude/commands/*.md`           |
| Memory/CLAUDE.md | `CLAUDE.md` or `.claude/CLAUDE.md` |
| Plugins       | Via `plugins` option               |

Control which sources load with `setting_sources` (Python) / `settingSources` (TypeScript).

### Compatibility note

Opus 4.7 (`claude-opus-4-7`) requires Agent SDK v0.2.111 or later.

## Full Documentation

For the complete official documentation, see the reference files:

- [Overview](references/claude-code-agent-sdk-overview.md) — SDK introduction, built-in tools, capabilities overview, comparison with Client SDK and CLI
- [Quickstart](references/claude-code-agent-sdk-quickstart.md) — step-by-step: install, set API key, build a bug-fixing agent, key concepts, troubleshooting
- [Agent loop](references/claude-code-agent-sdk-agent-loop.md) — how turns, messages, and context accumulate; handling results and errors
- [TypeScript SDK reference](references/claude-code-agent-sdk-typescript.md) — full API: `query()`, `startup()`, `tool()`, Options, message types, hook input/output types
- [Python SDK reference](references/claude-code-agent-sdk-python.md) — full API: `query()`, `ClaudeSDKClient`, `ClaudeAgentOptions`, message types, hook input/output types
- [TypeScript V2 preview](references/claude-code-agent-sdk-typescript-v2-preview.md) — new `createSession()`, `send()`, `stream()` patterns
- [Sessions](references/claude-code-agent-sdk-sessions.md) — continue, resume, fork; automatic session management; cross-host resume
- [Hooks](references/claude-code-agent-sdk-hooks.md) — SDK callback hooks: configuration, matchers, callback inputs/outputs, async hooks, examples
- [Permissions](references/claude-code-agent-sdk-permissions.md) — permission modes, allow/deny rules, evaluation order, dynamic mode changes
- [User input](references/claude-code-agent-sdk-user-input.md) — `canUseTool` callback, `AskUserQuestion` tool, handling interactive approval
- [Subagents](references/claude-code-agent-sdk-subagents.md) — spawning specialized agents, `AgentDefinition`, tracking subagent messages
- [Custom tools](references/claude-code-agent-sdk-custom-tools.md) — define MCP tools with `tool()`, in-process MCP servers
- [MCP](references/claude-code-agent-sdk-mcp.md) — connecting external MCP servers, tool naming conventions
- [Streaming output](references/claude-code-agent-sdk-streaming-output.md) — message types and processing the output stream
- [Streaming vs single-turn mode](references/claude-code-agent-sdk-streaming-vs-single-mode.md) — when to use each input mode, image support
- [Structured outputs](references/claude-code-agent-sdk-structured-outputs.md) — extracting typed/JSON data from agent runs
- [Modifying system prompts](references/claude-code-agent-sdk-modifying-system-prompts.md) — `system_prompt`, `append_system_prompt`, CLAUDE.md memory
- [Claude Code features](references/claude-code-agent-sdk-claude-code-features.md) — skills, slash commands, plugins via SDK
- [Skills](references/claude-code-agent-sdk-skills.md) — loading and using skills from SDK agents
- [Slash commands](references/claude-code-agent-sdk-slash-commands.md) — custom commands available to SDK agents
- [Plugins](references/claude-code-agent-sdk-plugins.md) — loading plugins programmatically
- [File checkpointing](references/claude-code-agent-sdk-file-checkpointing.md) — snapshot and revert filesystem changes across sessions
- [Todo tracking](references/claude-code-agent-sdk-todo-tracking.md) — agent task planning and progress tracking
- [Tool search](references/claude-code-agent-sdk-tool-search.md) — `ToolSearch` for deferred tool schema loading
- [Cost tracking](references/claude-code-agent-sdk-cost-tracking.md) — `total_cost_usd` on ResultMessage, budget limits
- [Observability](references/claude-code-agent-sdk-observability.md) — logging, telemetry, monitoring SDK agents
- [Hosting](references/claude-code-agent-sdk-hosting.md) — deploying to Docker, cloud, CI/CD
- [Secure deployment](references/claude-code-agent-sdk-secure-deployment.md) — security best practices for production agents
- [Migration guide](references/claude-code-agent-sdk-migration-guide.md) — migrating from Claude Code SDK to Claude Agent SDK

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
- Skills: https://code.claude.com/docs/en/agent-sdk/skills.md
- Slash commands: https://code.claude.com/docs/en/agent-sdk/slash-commands.md
- Streaming output: https://code.claude.com/docs/en/agent-sdk/streaming-output.md
- Streaming vs single-turn mode: https://code.claude.com/docs/en/agent-sdk/streaming-vs-single-mode.md
- Structured outputs: https://code.claude.com/docs/en/agent-sdk/structured-outputs.md
- Subagents: https://code.claude.com/docs/en/agent-sdk/subagents.md
- Todo tracking: https://code.claude.com/docs/en/agent-sdk/todo-tracking.md
- Tool search: https://code.claude.com/docs/en/agent-sdk/tool-search.md
- TypeScript SDK reference: https://code.claude.com/docs/en/agent-sdk/typescript.md
- TypeScript V2 preview: https://code.claude.com/docs/en/agent-sdk/typescript-v2-preview.md
- User input: https://code.claude.com/docs/en/agent-sdk/user-input.md
