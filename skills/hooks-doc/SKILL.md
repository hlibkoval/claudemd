---
name: hooks-doc
description: Complete documentation for Claude Code hooks -- lifecycle hook events (SessionStart, UserPromptSubmit, PreToolUse, PermissionRequest, PostToolUse, PostToolUseFailure, Notification, SubagentStart, SubagentStop, Stop, TeammateIdle, TaskCompleted, InstructionsLoaded, ConfigChange, WorktreeCreate, WorktreeRemove, PreCompact, SessionEnd), hook types (command, http, prompt, agent), configuration schema, matcher patterns, JSON input/output formats, exit codes, decision control (allow/deny/ask/block), structured JSON output (hookSpecificOutput, permissionDecision, updatedInput, additionalContext), async hooks, HTTP hooks with env var interpolation, prompt-based and agent-based hooks, hook locations (user/project/local/managed/plugin/skill frontmatter), environment variable persistence (CLAUDE_ENV_FILE), the /hooks menu, security considerations, and debugging. Load when discussing Claude Code hooks, lifecycle hooks, hook events, PreToolUse, PostToolUse, Stop hooks, hook matchers, hook configuration, settings.json hooks, shell command hooks, hook input/output, exit codes for hooks, blocking tool calls, auto-formatting after edits, desktop notifications, permission hooks, or any automation of Claude Code's lifecycle.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks -- user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle.

## Quick Reference

### Hook Events

| Event | When it fires | Can block? | Matcher field |
|:------|:-------------|:-----------|:--------------|
| `SessionStart` | Session begins or resumes | No | source: `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | No matcher support |
| `UserPromptSubmit` | User submits a prompt | Yes | No matcher support |
| `PreToolUse` | Before a tool call executes | Yes | tool name: `Bash`, `Edit\|Write`, `mcp__.*` |
| `PermissionRequest` | Permission dialog appears | Yes | tool name |
| `PostToolUse` | After a tool call succeeds | No | tool name |
| `PostToolUseFailure` | After a tool call fails | No | tool name |
| `Notification` | Notification sent | No | type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | agent type: `Bash`, `Explore`, `Plan`, custom |
| `SubagentStop` | Subagent finishes | Yes | agent type |
| `Stop` | Claude finishes responding | Yes | No matcher support |
| `TeammateIdle` | Teammate about to go idle | Yes | No matcher support |
| `TaskCompleted` | Task marked as completed | Yes | No matcher support |
| `ConfigChange` | Config file changes | Yes | source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `WorktreeCreate` | Worktree being created | Yes | No matcher support |
| `WorktreeRemove` | Worktree being removed | No | No matcher support |
| `PreCompact` | Before compaction | No | trigger: `manual`, `auto` |
| `SessionEnd` | Session terminates | No | reason: `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook Types

| Type | Description | Default timeout |
|:-----|:------------|:----------------|
| `command` | Run a shell command (stdin JSON, exit codes, stdout/stderr) | 600s |
| `http` | POST event data to a URL, response body for results | 600s |
| `prompt` | Single-turn LLM evaluation, returns `{ok, reason}` | 30s |
| `agent` | Multi-turn subagent with tool access, returns `{ok, reason}` | 60s |

Events supporting all four types: `PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCompleted`. All other events support `command` only.

### Hook Handler Fields

#### Common fields (all types)

| Field | Required | Description |
|:------|:---------|:------------|
| `type` | yes | `"command"`, `"http"`, `"prompt"`, or `"agent"` |
| `timeout` | no | Seconds before canceling |
| `statusMessage` | no | Custom spinner message while hook runs |
| `once` | no | If `true`, runs only once per session (skills only) |

#### Command-specific fields

| Field | Required | Description |
|:------|:---------|:------------|
| `command` | yes | Shell command to execute |
| `async` | no | If `true`, runs in background without blocking |

#### HTTP-specific fields

| Field | Required | Description |
|:------|:---------|:------------|
| `url` | yes | URL to POST to |
| `headers` | no | Key-value headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | no | Env var names allowed in header interpolation |

#### Prompt/agent-specific fields

| Field | Required | Description |
|:------|:---------|:------------|
| `prompt` | yes | Prompt text; `$ARGUMENTS` placeholder for hook input JSON |
| `model` | no | Model to use (defaults to fast model) |

### Hook Locations

| Location | Scope | Shareable |
|:---------|:------|:----------|
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes (committed) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes (bundled) |
| Skill/agent YAML frontmatter | While component active | Yes |

### Exit Code Behavior

| Exit code | Meaning |
|:----------|:--------|
| **0** | Success -- action proceeds; stdout parsed for JSON output |
| **2** | Blocking error -- action blocked; stderr fed to Claude as feedback |
| **Other** | Non-blocking error -- stderr logged in verbose mode; execution continues |

### Common Input Fields (all events)

| Field | Description |
|:------|:------------|
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | (subagent only) Unique subagent identifier |
| `agent_type` | (agent/subagent only) Agent name |

### JSON Output Fields (universal)

| Field | Default | Description |
|:------|:--------|:------------|
| `continue` | `true` | If `false`, Claude stops entirely (overrides event-specific decisions) |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | If `true`, hides stdout from verbose mode |
| `systemMessage` | none | Warning message shown to user |

### Decision Control by Event

| Events | Decision pattern | Key fields |
|:-------|:----------------|:-----------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code 2 or `continue: false` | stderr feedback or `stopReason` |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| WorktreeCreate | stdout path | Print absolute worktree path; non-zero exit fails creation |
| WorktreeRemove, Notification, SessionEnd, PreCompact, InstructionsLoaded | None | Side-effect only (logging, cleanup) |

### PreToolUse Tool Input Schemas

| Tool | Key fields |
|:-----|:-----------|
| Bash | `command`, `description`, `timeout`, `run_in_background` |
| Write | `file_path`, `content` |
| Edit | `file_path`, `old_string`, `new_string`, `replace_all` |
| Read | `file_path`, `offset`, `limit` |
| Glob | `pattern`, `path` |
| Grep | `pattern`, `path`, `glob`, `output_mode`, `-i`, `multiline` |
| WebFetch | `url`, `prompt` |
| WebSearch | `query`, `allowed_domains`, `blocked_domains` |
| Agent | `prompt`, `description`, `subagent_type`, `model` |

### Environment Variables for Hooks

| Variable | Description |
|:---------|:------------|
| `$CLAUDE_PROJECT_DIR` | Project root (use in command paths) |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory |
| `$CLAUDE_ENV_FILE` | File path for persisting env vars (SessionStart hooks only) |
| `$CLAUDE_CODE_REMOTE` | Set to `"true"` in remote web environments |

### MCP Tool Naming

MCP tools follow the pattern `mcp__<server>__<tool>`. Match with regex patterns:
- `mcp__memory__.*` -- all tools from memory server
- `mcp__.*__write.*` -- any write tool from any server

### Async Hooks

Set `"async": true` on command hooks to run in background. Async hooks cannot block actions or return decisions. Output delivered via `systemMessage` or `additionalContext` on next conversation turn.

### Prompt/Agent Hook Response Schema

```
{ "ok": true }              -- allow the action
{ "ok": false, "reason": "..." }  -- block with explanation
```

### Key Behaviors

- All matching hooks run in parallel; identical handlers are deduplicated
- Direct edits to settings files require review in `/hooks` menu or session restart
- `disableAllHooks: true` disables all hooks; managed hooks can only be disabled at the managed level
- `stop_hook_active` field in Stop/SubagentStop input prevents infinite loops
- HTTP hooks: non-2xx or connection failures are non-blocking; must return 2xx with JSON body to block
- SessionStart: stdout text added as context for Claude; `CLAUDE_ENV_FILE` for persistent env vars
- Skill/agent frontmatter hooks: scoped to component lifetime; `Stop` auto-converts to `SubagentStop` for agents; `once: true` supported in skills

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) -- full event schemas, JSON input/output formats, configuration schema, matcher patterns, hook handler fields (command/http/prompt/agent), decision control per event, PreToolUse tool input schemas, async hooks, prompt-based hooks, agent-based hooks, security considerations, and debugging
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) -- getting started with /hooks menu, common automation patterns (notifications, auto-format, file protection, context re-injection, config auditing), how hooks work, matchers, hook locations, prompt-based hooks, agent-based hooks, HTTP hooks, limitations, and troubleshooting

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
