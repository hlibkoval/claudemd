---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — lifecycle events, configuration schema, matchers, exit codes, JSON output, command/HTTP/prompt/agent hook types, async hooks, environment variables, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute at specific points in Claude Code's lifecycle. They provide deterministic control over behavior: format files after edits, block dangerous commands, send notifications, inject context, auto-approve permissions, and more.

### Hook events

| Event                | When it fires                                                        | Can block? | Matcher filters on              |
| :------------------- | :------------------------------------------------------------------- | :--------- | :------------------------------ |
| `SessionStart`       | Session begins or resumes                                            | No         | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or `.claude/rules/*.md` loaded into context                | No         | load reason                     |
| `UserPromptSubmit`   | User submits a prompt, before processing                             | Yes        | no matcher support              |
| `PreToolUse`         | Before a tool call executes                                          | Yes        | tool name                       |
| `PermissionRequest`  | Permission dialog is about to show                                   | Yes        | tool name                       |
| `PermissionDenied`   | Auto mode classifier denies a tool call                              | No         | tool name                       |
| `PostToolUse`        | After a tool call succeeds                                           | No         | tool name                       |
| `PostToolUseFailure` | After a tool call fails                                              | No         | tool name                       |
| `Notification`       | Claude sends a notification                                          | No         | notification type               |
| `SubagentStart`      | Subagent spawned                                                     | No         | agent type                      |
| `SubagentStop`       | Subagent finishes                                                    | Yes        | agent type                      |
| `TaskCreated`        | Task created via TaskCreate                                          | Yes        | no matcher support              |
| `TaskCompleted`      | Task marked completed                                                | Yes        | no matcher support              |
| `Stop`               | Claude finishes responding                                           | Yes        | no matcher support              |
| `StopFailure`        | Turn ends due to API error                                           | No         | error type                      |
| `TeammateIdle`       | Agent team teammate about to go idle                                 | Yes        | no matcher support              |
| `ConfigChange`       | Configuration file changes during session                            | Yes        | config source                   |
| `CwdChanged`         | Working directory changes                                            | No         | no matcher support              |
| `FileChanged`        | Watched file changes on disk                                         | No         | literal filenames               |
| `WorktreeCreate`     | Worktree being created                                               | Yes        | no matcher support              |
| `WorktreeRemove`     | Worktree being removed                                               | No         | no matcher support              |
| `PreCompact`         | Before context compaction                                            | Yes        | `manual`, `auto`                |
| `PostCompact`        | After context compaction completes                                   | No         | `manual`, `auto`                |
| `Elicitation`        | MCP server requests user input                                       | Yes        | MCP server name                 |
| `ElicitationResult`  | User responds to MCP elicitation                                     | Yes        | MCP server name                 |
| `SessionEnd`         | Session terminates                                                   | No         | exit reason                     |

### Hook types

| Type      | What it does                                            | Default timeout |
| :-------- | :------------------------------------------------------ | :-------------- |
| `command` | Runs a shell command; receives JSON on stdin             | 600s            |
| `http`    | POSTs event JSON to a URL; reads response body           | 600s            |
| `prompt`  | Single-turn LLM evaluation; returns `ok`/`reason` JSON  | 30s             |
| `agent`   | Multi-turn subagent with tool access; same response format | 60s           |

`SessionStart` supports only `command`. Events that support all four types: `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` (command/http only), `UserPromptSubmit`, `Stop`, `SubagentStop`, `TaskCreated`, `TaskCompleted`. All other events support `command` and `http` only.

### Configuration structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<filter>",
        "hooks": [
          {
            "type": "command",
            "command": "your-script.sh",
            "if": "Bash(git *)",
            "timeout": 30,
            "async": false,
            "statusMessage": "Running hook..."
          }
        ]
      }
    ]
  }
}
```

### Hook handler fields

Common fields (all types): `type` (required), `if`, `timeout`, `statusMessage`, `once`.

| Type      | Extra fields                                                |
| :-------- | :---------------------------------------------------------- |
| `command` | `command` (required), `async`, `asyncRewake`, `shell`       |
| `http`    | `url` (required), `headers`, `allowedEnvVars`               |
| `prompt`  | `prompt` (required), `model`                                |
| `agent`   | `prompt` (required), `model`                                |

The `if` field uses permission rule syntax (e.g., `"Bash(git *)"`, `"Edit(*.ts)"`) to narrow when a handler spawns. Only evaluated on tool events; adding `if` to other events prevents the hook from running.

### Hook locations (scope)

| Location                            | Scope                  | Shareable             |
| :---------------------------------- | :--------------------- | :-------------------- |
| `~/.claude/settings.json`           | All projects           | No                    |
| `.claude/settings.json`             | Single project         | Yes (commit it)       |
| `.claude/settings.local.json`       | Single project         | No (gitignored)       |
| Managed policy settings             | Organization-wide      | Admin-controlled      |
| Plugin `hooks/hooks.json`           | When plugin is enabled | Bundled with plugin   |
| Skill or agent frontmatter          | While component active | Defined in the file   |

Set `"disableAllHooks": true` in settings to disable all hooks. Managed hooks respect managed settings hierarchy.

### Matcher patterns

| Matcher value                        | Evaluated as             | Example                            |
| :----------------------------------- | :----------------------- | :--------------------------------- |
| `"*"`, `""`, or omitted             | Match all                | Fires every occurrence             |
| Only letters, digits, `_`, and `\|` | Exact string or `\|`-list | `Bash`, `Edit\|Write`              |
| Contains any other character         | JavaScript regex         | `mcp__memory__.*`, `^Notebook`     |

MCP tools follow `mcp__<server>__<tool>` naming. Use `mcp__memory__.*` to match all tools from a server.

### Exit codes

| Exit code | Effect                                                                 |
| :-------- | :--------------------------------------------------------------------- |
| 0         | Action proceeds. Stdout parsed for JSON output                         |
| 2         | Action blocked. Stderr fed back to Claude as feedback                  |
| Other     | Non-blocking error. Transcript shows notice; execution continues       |

Exception: `WorktreeCreate` fails on any non-zero exit code.

### JSON output (exit 0)

Universal fields: `continue` (default `true`; set `false` to halt Claude entirely), `stopReason`, `suppressOutput`, `systemMessage`.

#### Decision control by event

| Events                                                                        | Pattern                   | Key fields                                             |
| :---------------------------------------------------------------------------- | :------------------------ | :----------------------------------------------------- |
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange, PreCompact | Top-level `decision`      | `decision: "block"`, `reason`                          |
| PreToolUse                                                                    | `hookSpecificOutput`      | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| PermissionRequest                                                             | `hookSpecificOutput`      | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message` |
| PermissionDenied                                                              | `hookSpecificOutput`      | `retry: true` lets model retry                         |
| TeammateIdle, TaskCreated, TaskCompleted                                      | Exit code or `continue`   | Exit 2 blocks; `{"continue": false}` stops teammate    |
| WorktreeCreate                                                                | Path return               | Stdout = worktree path (command); `hookSpecificOutput.worktreePath` (http) |

### Common input fields (stdin JSON)

All events: `session_id`, `transcript_path`, `cwd`, `hook_event_name`. Most events also include `permission_mode`. Subagent contexts add `agent_id` and `agent_type`.

### Environment variables

| Variable               | Available in                            | Purpose                                          |
| :--------------------- | :-------------------------------------- | :----------------------------------------------- |
| `$CLAUDE_PROJECT_DIR`  | All hooks                               | Project root; use to reference scripts            |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hooks                            | Plugin installation directory                     |
| `${CLAUDE_PLUGIN_DATA}` | Plugin hooks                            | Plugin persistent data directory                  |
| `$CLAUDE_ENV_FILE`     | SessionStart, CwdChanged, FileChanged   | Write `export` statements to persist env vars     |
| `$CLAUDE_CODE_REMOTE`  | All hooks                               | `"true"` in remote web environments               |

### Async hooks

Set `"async": true` on command hooks to run in the background. Claude continues immediately; output delivered on next turn. Cannot block actions. Set `"asyncRewake": true` to wake Claude on exit code 2.

### Prompt and agent hook response

Both return: `{"ok": true}` to allow, or `{"ok": false, "reason": "..."}` to block. Agent hooks can use Read, Grep, and Glob tools (up to 50 turns).

### Key patterns

**Auto-format after edits**: `PostToolUse` + matcher `Edit|Write` + command running prettier/formatter.

**Block protected files**: `PreToolUse` + matcher `Edit|Write` + script checking paths, exit 2 to block.

**Notification on idle**: `Notification` + platform-native notification command (`osascript`, `notify-send`, `powershell`).

**Re-inject context after compaction**: `SessionStart` + matcher `compact` + echo important reminders.

**Auto-approve permission**: `PermissionRequest` + matcher on tool name + return `{"hookSpecificOutput": {"hookEventName": "PermissionRequest", "decision": {"behavior": "allow"}}}`.

**Persist environment variables**: Write `export VAR=value` lines to `$CLAUDE_ENV_FILE` in SessionStart, CwdChanged, or FileChanged hooks.

### PreToolUse permission precedence

Hooks fire before permission-mode checks. A hook returning `deny` blocks even in `bypassPermissions` mode. A hook returning `allow` does NOT override deny rules from settings. Precedence when multiple hooks return different decisions: `deny` > `defer` > `ask` > `allow`.

### Troubleshooting

- **Hook not firing**: run `/hooks` to verify configuration; check matcher is case-sensitive and exact; verify correct event type; `PermissionRequest` hooks do not fire in non-interactive mode (`-p`).
- **Hook error in transcript**: test script manually with `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | ./my-hook.sh`; use absolute paths or `$CLAUDE_PROJECT_DIR`; ensure `chmod +x`.
- **JSON validation failed**: shell profile `echo` statements prepend text to JSON output; wrap in `if [[ $- == *i* ]]` guard.
- **Stop hook runs forever**: check `stop_hook_active` field in input; exit 0 when `true`.
- **Debug**: `claude --debug-file /tmp/claude.log` for full hook execution details; `/debug` mid-session; `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher details.
- **Output cap**: hook output injected into context is capped at 10,000 characters.

## Full Documentation

For the complete official documentation, see the reference files:

- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, exit codes, matcher patterns, configuration options, async hooks, HTTP hooks, prompt-based and agent-based hooks, MCP tool hooks, worktree hooks, permission update entries, `defer` for non-interactive mode, security considerations, and debug logging.
- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — getting-started guide with step-by-step setup, common automation patterns (notifications, auto-format, file protection, context re-injection, config auditing, env reload, auto-approval), hook types overview, matcher examples, `if` field filtering, prompt-based and agent-based hooks, HTTP hooks, and troubleshooting.

## Sources

- Hooks reference: https://code.claude.com/docs/en/hooks.md
- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
