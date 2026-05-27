---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events (SessionStart, Setup, PreToolUse, PostToolUse, PostToolUseFailure, PostToolBatch, PermissionRequest, PermissionDenied, Stop, StopFailure, Notification, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd), hook types (command, http, mcp_tool, prompt, agent), matcher patterns, exit codes, JSON input/output formats, decision control, async hooks, env var persistence, security considerations.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### What Hooks Are

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior and integrate it with external tools.

### Hook Event Reference

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `-p --init/--maintenance` | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | Slash command expands into a prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog about to appear | Yes (allow/deny) |
| `PermissionDenied` | Auto mode classifier denies a tool call | No (retry only) |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After all parallel tool calls resolve | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` | Subagent spawned | No |
| `SubagentStop` | Subagent finishes | Yes |
| `TaskCreated` | Task created via `TaskCreate` | Yes |
| `TaskCompleted` | Task marked as completed | Yes |
| `Stop` | Claude finishes responding | Yes |
| `StopFailure` | Turn ends due to API error | No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No |
| `ConfigChange` | Configuration file changes | Yes (except policy) |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero) |
| `WorktreeRemove` | Worktree being removed | No |
| `PreCompact` | Before context compaction | Yes |
| `PostCompact` | After context compaction | No |
| `Elicitation` | MCP server requests user input | Yes |
| `ElicitationResult` | User responds to MCP elicitation | Yes |
| `SessionEnd` | Session terminates | No |

### Hook Types

| Type | Description | Supported events |
| :--- | :--- | :--- |
| `command` | Run a shell command | All events |
| `http` | POST event data to a URL | All except SessionStart, Setup |
| `mcp_tool` | Call a tool on a connected MCP server | All except SessionStart, Setup |
| `prompt` | Single-turn LLM evaluation (Haiku by default) | Most events (not SessionStart, Setup) |
| `agent` | Multi-turn subagent with tool access (experimental) | Same as `prompt` |

### Configuration Structure

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write $(jq -r '.tool_input.file_path')"
          }
        ]
      }
    ]
  }
}
```

Three levels: **hook event** → **matcher group** → **hook handler(s)**.

### Hook Locations

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill or agent frontmatter | While component is active | Yes |

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-separated list |
| Contains any other character | JavaScript regular expression |

Events that match on tool name: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`

Events with no matcher support (always fire): `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged`

MCP tools follow the naming pattern `mcp__<server>__<tool>`. Use `mcp__memory__.*` to match all tools from a server.

### `if` Field (Fine-grained filtering)

Available on tool events only (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). Requires Claude Code v2.1.85+.

Uses permission rule syntax to filter on tool name and arguments together:
- `"Bash(git *)"` — fires only for Bash subcommands matching `git *`
- `"Edit(*.ts)"` — fires only for TypeScript file edits

### Common Hook Handler Fields

| Field | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| `type` | Yes | — | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | — | Permission rule syntax for fine-grained filtering (tool events only) |
| `timeout` | No | 600s (command/http/mcp_tool), 30s (prompt), 60s (agent) | Seconds before canceling |
| `statusMessage` | No | — | Custom spinner message while hook runs |
| `once` | No | `false` | Run once per session then removed (skill frontmatter only) |

### Command Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `command` | Yes | Shell command. When `args` present: executable to spawn directly (exec form) |
| `args` | No | Argument vector. Enables exec form (no shell, no tokenization) |
| `async` | No | Run in background without blocking |
| `asyncRewake` | No | Async + wakes Claude on exit code 2 |
| `shell` | No | `"bash"` (default) or `"powershell"` (Windows) |

**Path placeholders:** `${CLAUDE_PROJECT_DIR}`, `${CLAUDE_PLUGIN_ROOT}`, `${CLAUDE_PLUGIN_DATA}`

### HTTP Hook Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `url` | Yes | URL to POST to |
| `headers` | No | Key-value headers; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | No | Env vars allowed to be interpolated into header values |

### Exit Codes

| Exit code | Meaning |
| :--- | :--- |
| `0` | No objection; stdout is parsed for JSON output |
| `2` | Blocking error; stderr is shown to Claude as feedback |
| Other | Non-blocking error; transcript shows one-line notice |

For `WorktreeCreate`, any non-zero exit code fails creation.

### JSON Output Fields (Universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | `false` stops Claude entirely after hook runs |
| `stopReason` | — | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Hides hook stdout from transcript |
| `systemMessage` | — | Warning message shown to user |
| `terminalSequence` | — | Terminal escape sequence for Claude Code to emit (OSC 0/1/2/9/99/777, BEL). Requires v2.1.141+ |

Hook stdout is capped at 10,000 characters.

### Decision Control by Event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | Exit 2 blocks action with stderr; JSON stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` tells model it may retry |
| `WorktreeCreate` | Path return | Command hook prints path on stdout; HTTP uses `hookSpecificOutput.worktreePath` |
| `Elicitation` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `SessionStart`, `Setup`, `SubagentStart` | Context only | `additionalContext`; no blocking |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side effects only |

### PreToolUse `permissionDecision` Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skip interactive permission prompt (deny rules still apply) |
| `"deny"` | Cancel the tool call; `permissionDecisionReason` sent to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Exit with tool call preserved for Agent SDK wrapper to resume (non-interactive `-p` mode only; requires v2.1.89+) |

When multiple `PreToolUse` hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Current working directory when hook is invoked |
| `permission_mode` | Current permission mode |
| `effort` | Active effort level object (`level` field) |
| `hook_event_name` | Name of the event that fired |

### Persist Environment Variables (`CLAUDE_ENV_FILE`)

Available for `SessionStart`, `Setup`, `CwdChanged`, and `FileChanged` hooks. Write `export` statements to `$CLAUDE_ENV_FILE`; those variables are then available in all subsequent Bash commands:

```bash
echo 'export NODE_ENV=production' >> "$CLAUDE_ENV_FILE"
```

### Async Hooks

Set `"async": true` on `type: "command"` hooks to run in the background. The hook receives the same JSON input but cannot block or return decisions. After completion, `additionalContext` is delivered on the next conversation turn. `asyncRewake: true` causes Claude to wake immediately on exit code 2.

### Prompt-Based Hook Response Schema

Prompt and agent hooks return:
```json
{ "ok": true }
// or
{ "ok": false, "reason": "explanation" }
```

`ok: false` on `Stop`/`SubagentStop` feeds `reason` back to Claude as its next instruction. On `PreToolUse`, it denies the call. On `PostToolUse`, it ends the turn (or continues if `continueOnBlock: true`).

### `additionalContext` Field

Return inside `hookSpecificOutput` alongside `hookEventName`. Claude Code wraps it in a system reminder inserted at the current point. Use for environment state, conditional rules, or external data. For static instructions, use CLAUDE.md instead.

### Stop Hook: Block Cap

Claude Code overrides a Stop hook after 8 consecutive blocks. Check `stop_hook_active` in input and exit early if `true`:

```bash
if [ "$(jq -r '.stop_hook_active')" = "true" ]; then exit 0; fi
```

Raise the cap with `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

### Debug Hooks

Start with `claude --debug-file /tmp/claude.log` or run `/debug` mid-session. For verbose matcher details, set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`. The transcript view (`Ctrl+O`) shows one-line summaries for each hook that fired.

### Security

Command hooks run with your full user permissions. Best practices: validate and sanitize inputs, always quote shell variables (`"$VAR"`), block path traversal (`..`), use absolute paths, avoid `.env`/`.git/` in hook scripts.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — setup walkthrough, common use cases (notifications, auto-format, file protection, context re-injection, config auditing, env reload, auto-approval), how hooks work, prompt-based hooks, agent-based hooks, HTTP hooks, limitations and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit codes, decision control tables, all hook types (command, http, mcp_tool, prompt, agent), async hooks, security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
