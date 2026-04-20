---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, shell command/HTTP/prompt/agent hook types, matchers, JSON input/output, exit codes, decision control, async hooks, permission hooks, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior, ensuring certain actions always happen rather than relying on the LLM to choose to run them.

### Hook types

| Type      | Description                                              | Default timeout |
| :-------- | :------------------------------------------------------- | :-------------- |
| `command` | Run a shell command; receives JSON on stdin               | 600s            |
| `http`    | POST event JSON to a URL; reads response body             | 600s            |
| `prompt`  | Single-turn LLM evaluation (Haiku by default)             | 30s             |
| `agent`   | Multi-turn subagent with tool access (Read, Grep, etc.)   | 60s             |

### Hook events

| Event                | When it fires                                                   | Can block? | Matcher filters on           |
| :------------------- | :-------------------------------------------------------------- | :--------- | :--------------------------- |
| `SessionStart`       | Session begins or resumes                                       | No         | source (`startup`, `resume`, `clear`, `compact`) |
| `UserPromptSubmit`   | User submits a prompt, before processing                        | Yes        | no matcher support           |
| `PreToolUse`         | Before a tool call executes                                     | Yes        | tool name                    |
| `PermissionRequest`  | Permission dialog appears                                       | Yes        | tool name                    |
| `PermissionDenied`   | Auto mode classifier denies a tool call                         | No         | tool name                    |
| `PostToolUse`        | After a tool call succeeds                                      | No         | tool name                    |
| `PostToolUseFailure` | After a tool call fails                                         | No         | tool name                    |
| `Notification`       | Claude Code sends a notification                                | No         | notification type            |
| `SubagentStart`      | Subagent spawned                                                | No         | agent type                   |
| `SubagentStop`       | Subagent finishes                                               | Yes        | agent type                   |
| `TaskCreated`        | Task being created via TaskCreate                               | Yes        | no matcher support           |
| `TaskCompleted`      | Task being marked completed                                     | Yes        | no matcher support           |
| `Stop`               | Claude finishes responding                                      | Yes        | no matcher support           |
| `StopFailure`        | Turn ends due to API error                                      | No         | error type                   |
| `TeammateIdle`       | Agent team teammate about to go idle                            | Yes        | no matcher support           |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context                     | No         | load reason                  |
| `ConfigChange`       | Configuration file changes during session                       | Yes        | config source                |
| `CwdChanged`         | Working directory changes                                       | No         | no matcher support           |
| `FileChanged`        | Watched file changes on disk                                    | No         | literal filenames            |
| `WorktreeCreate`     | Worktree being created                                          | Yes        | no matcher support           |
| `WorktreeRemove`     | Worktree being removed                                          | No         | no matcher support           |
| `PreCompact`         | Before context compaction                                       | Yes        | trigger (`manual`, `auto`)   |
| `PostCompact`        | After context compaction                                        | No         | trigger (`manual`, `auto`)   |
| `Elicitation`        | MCP server requests user input                                  | Yes        | MCP server name              |
| `ElicitationResult`  | After user responds to MCP elicitation                          | Yes        | MCP server name              |
| `SessionEnd`         | Session terminates                                              | No         | exit reason                  |

### Configuration structure

Hooks are defined in settings JSON files with three nesting levels:

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<pattern>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh"
          }
        ]
      }
    ]
  }
}
```

### Hook locations (scope)

| Location                           | Scope                   | Shareable                  |
| :--------------------------------- | :---------------------- | :------------------------- |
| `~/.claude/settings.json`          | All projects            | No                         |
| `.claude/settings.json`            | Single project          | Yes (commit to repo)       |
| `.claude/settings.local.json`      | Single project          | No (gitignored)            |
| Managed policy settings            | Organization-wide       | Yes (admin-controlled)     |
| Plugin `hooks/hooks.json`          | When plugin is enabled  | Yes (bundled with plugin)  |
| Skill or agent frontmatter         | While component active  | Yes (defined in component) |

### Handler fields

Common fields for all hook types:

| Field           | Required | Description                                                          |
| :-------------- | :------- | :------------------------------------------------------------------- |
| `type`          | yes      | `"command"`, `"http"`, `"prompt"`, or `"agent"`                      |
| `if`            | no       | Permission rule syntax filter, e.g. `"Bash(git *)"`, `"Edit(*.ts)"` |
| `timeout`       | no       | Seconds before canceling                                             |
| `statusMessage` | no       | Custom spinner message while hook runs                               |
| `once`          | no       | If `true`, runs once per session then removed (skill frontmatter only) |

Command-specific: `command`, `async`, `asyncRewake`, `shell` (`"bash"` or `"powershell"`).
HTTP-specific: `url`, `headers`, `allowedEnvVars`.
Prompt/agent-specific: `prompt` (use `$ARGUMENTS` for hook input), `model`.

### Matcher patterns

| Matcher value                       | Evaluated as                    |
| :---------------------------------- | :------------------------------ |
| `"*"`, `""`, or omitted            | Match all                       |
| Only letters, digits, `_`, and `\|` | Exact string or pipe-separated list |
| Contains any other character        | JavaScript regular expression   |

MCP tools follow `mcp__<server>__<tool>` naming. Match all from a server: `mcp__memory__.*`

### Exit codes

| Exit code | Meaning                                                       |
| :-------- | :------------------------------------------------------------ |
| `0`       | Success; action proceeds. stdout parsed for JSON if present   |
| `2`       | Block the action (for events that support blocking)           |
| Other     | Non-blocking error; action proceeds; stderr logged            |

### JSON output fields (universal)

| Field            | Default | Description                                            |
| :--------------- | :------ | :----------------------------------------------------- |
| `continue`       | `true`  | `false` stops Claude entirely                          |
| `stopReason`     | none    | Message shown to user when `continue` is `false`       |
| `suppressOutput` | `false` | Omit stdout from debug log                             |
| `systemMessage`  | none    | Warning message shown to user                          |

### Decision control patterns by event

| Events                                                               | Pattern                    | Key fields                                            |
| :------------------------------------------------------------------- | :------------------------- | :---------------------------------------------------- |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange, PreCompact | Top-level `decision`       | `decision: "block"`, `reason`                         |
| PreToolUse                                                           | `hookSpecificOutput`       | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest                                                    | `hookSpecificOutput`       | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` |
| PermissionDenied                                                     | `hookSpecificOutput`       | `retry: true` to allow model to retry                 |
| TeammateIdle, TaskCreated, TaskCompleted                             | Exit code or `continue`    | Exit 2 blocks; JSON `continue: false` stops teammate  |
| WorktreeCreate                                                       | Path return                | stdout = worktree path; HTTP uses `hookSpecificOutput.worktreePath` |
| Elicitation, ElicitationResult                                       | `hookSpecificOutput`       | `action` (accept/decline/cancel), `content`           |

### Common input fields (all events)

`session_id`, `transcript_path`, `cwd`, `permission_mode`, `hook_event_name`. In subagent context: `agent_id`, `agent_type`.

### Environment variables

| Variable               | Available in                        | Description                                  |
| :--------------------- | :---------------------------------- | :------------------------------------------- |
| `$CLAUDE_PROJECT_DIR`  | All hooks                           | Project root directory                       |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks                       | Plugin installation directory                |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks                       | Plugin persistent data directory             |
| `$CLAUDE_ENV_FILE`     | SessionStart, CwdChanged, FileChanged | Write `export` lines to persist env vars    |
| `$CLAUDE_CODE_REMOTE`  | All hooks                           | `"true"` in remote web environments          |

### Prompt and agent hooks response

Both use the same response schema:

```json
{ "ok": true }
```
```json
{ "ok": false, "reason": "Explanation shown to Claude" }
```

### Async hooks

Set `"async": true` on command hooks to run in background without blocking. Cannot return decisions. Results delivered on next conversation turn. Set `"asyncRewake": true` to wake Claude on exit code 2.

### Key limitations

- Command hooks communicate through stdout/stderr/exit codes only; cannot trigger `/` commands or tool calls
- Hook output injected into context is capped at 10,000 characters
- `PostToolUse` hooks cannot undo actions (tool already ran)
- `PermissionRequest` hooks do not fire in non-interactive mode (`-p`); use `PreToolUse` instead
- `Stop` hooks fire whenever Claude finishes responding, not only at task completion; check `stop_hook_active` to avoid infinite loops
- When multiple PreToolUse hooks return `updatedInput`, the last to finish wins (non-deterministic)
- PreToolUse hooks fire before permission-mode checks; `deny` blocks even in `bypassPermissions` mode
- `SessionEnd` hooks have a 1.5s default timeout (configurable per hook up to 60s budget)
- Set `"disableAllHooks": true` in settings to disable all hooks at once
- Enterprise: `allowManagedHooksOnly` blocks user/project/plugin hooks

### Debugging

- `/hooks` menu: read-only browser for configured hooks (shows event, matcher, type, source)
- `claude --debug-file /tmp/claude.log`: full hook execution details
- `/debug`: enable debug logging mid-session
- `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose`: granular matcher details
- Transcript view (`Ctrl+O`): one-line summary per hook

### Common troubleshooting

- **Hook not firing**: check `/hooks` menu; verify matcher is case-sensitive exact match; confirm correct event type
- **JSON validation failed**: shell profile `echo` statements pollute stdout; wrap in `if [[ $- == *i* ]]`
- **Stop hook runs forever**: check `stop_hook_active` field and exit early if `true`
- **Hook error in transcript**: test manually with `echo '{"tool_name":"Bash"}' | ./my-hook.sh`; use absolute paths; install `jq`

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit code behavior per event, configuration schema, matcher patterns, hook handler fields, decision control, async hooks, prompt-based hooks, agent-based hooks, HTTP hooks, WorktreeCreate/Remove, Elicitation, security considerations, and debugging.
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — getting-started guide with ready-to-use examples: desktop notifications, auto-formatting with Prettier, blocking edits to protected files, re-injecting context after compaction, auditing config changes, reloading environment on directory/file changes, auto-approving permission prompts, prompt-based and agent-based hooks, HTTP hooks, the `if` field for filtering by tool arguments, and troubleshooting.

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
