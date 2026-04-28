---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events, configuration schema, JSON input/output formats, exit codes, matchers, async hooks, HTTP hooks, prompt hooks, agent hooks, MCP tool hooks, and security considerations.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

Hooks are user-defined shell commands, HTTP endpoints, or LLM prompts that execute automatically at specific points in Claude Code's lifecycle. They provide deterministic control over Claude Code's behavior.

### Hook event reference

| Event | When it fires | Can block? | Matcher field |
| :--- | :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No | `startup`, `resume`, `clear`, `compact` |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded | No | `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `UserPromptSubmit` | User submits a prompt | Yes (exit 2) | no matcher |
| `UserPromptExpansion` | Slash command expands | Yes (exit 2) | command name |
| `PreToolUse` | Before tool call executes | Yes (exit 2 or JSON) | tool name |
| `PermissionRequest` | Permission dialog appears | Yes (JSON) | tool name |
| `PermissionDenied` | Auto-mode classifier denies call | No | tool name |
| `PostToolUse` | After tool call succeeds | No (feedback only) | tool name |
| `PostToolUseFailure` | After tool call fails | No (feedback only) | tool name |
| `PostToolBatch` | After full parallel tool batch | Yes (`decision: "block"`) | no matcher |
| `Notification` | Claude Code sends notification | No | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart` | Subagent spawned | No | agent type |
| `SubagentStop` | Subagent finishes | Yes (exit 2) | agent type |
| `TaskCreated` | Task created via TaskCreate | Yes (exit 2) | no matcher |
| `TaskCompleted` | Task marked completed | Yes (exit 2) | no matcher |
| `Stop` | Claude finishes responding | Yes (exit 2 or JSON) | no matcher |
| `StopFailure` | Turn ends due to API error | No | `rate_limit`, `authentication_failed`, `billing_error`, `invalid_request`, `server_error`, `max_output_tokens`, `unknown` |
| `TeammateIdle` | Agent team teammate goes idle | Yes (exit 2) | no matcher |
| `ConfigChange` | Config file changes | Yes (except `policy_settings`) | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `CwdChanged` | Working directory changes | No | no matcher |
| `FileChanged` | Watched file changes on disk | No | literal filenames (split on `\|`) |
| `WorktreeCreate` | Worktree being created | Yes (any non-zero exit) | — |
| `WorktreeRemove` | Worktree being removed | No | — |
| `PreCompact` | Before context compaction | Yes (exit 2) | `manual`, `auto` |
| `PostCompact` | After context compaction | No | `manual`, `auto` |
| `Elicitation` | MCP server requests user input | Yes (exit 2) | MCP server name |
| `ElicitationResult` | User responds to MCP elicitation | Yes (exit 2) | MCP server name |
| `SessionEnd` | Session terminates | No | `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |

### Hook configuration structure

```json
{
  "hooks": {
    "<EventName>": [
      {
        "matcher": "<filter>",
        "hooks": [
          {
            "type": "command",
            "command": "<shell command>"
          }
        ]
      }
    ]
  }
}
```

### Hook locations and scope

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All your projects | No |
| `.claude/settings.json` | Single project | Yes |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes, admin-controlled |
| Plugin `hooks/hooks.json` | When plugin is enabled | Yes |
| Skill or agent frontmatter | While component is active | Yes |

### Hook types

| Type | Description | Supports `async` |
| :--- | :--- | :--- |
| `command` | Shell command; reads JSON from stdin, returns via exit code/stdout | Yes |
| `http` | POST event JSON to a URL; returns via response body | No |
| `mcp_tool` | Calls a tool on a connected MCP server | No |
| `prompt` | Single-turn LLM evaluation; returns `{"ok": true/false, "reason": "..."}` | No |
| `agent` | Multi-turn subagent with tool access; experimental | No |

### Common hook handler fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | no | Permission rule syntax to filter by tool name+args (tool events only), e.g. `"Bash(git *)"` |
| `timeout` | no | Seconds before canceling (defaults: 600 command, 30 prompt, 60 agent) |
| `statusMessage` | no | Custom spinner text while hook runs |
| `once` | no | If `true`, runs once per session (skill frontmatter only) |

### Command hook fields

| Field | Description |
| :--- | :--- |
| `command` | Shell command to execute |
| `async` | If `true`, runs in background without blocking |
| `asyncRewake` | If `true`, background hook wakes Claude on exit 2 |
| `shell` | `"bash"` (default) or `"powershell"` |

### Exit code behavior

| Exit code | Meaning |
| :--- | :--- |
| 0 | Success; JSON stdout is parsed for structured control |
| 2 | Blocking error; stderr fed back to Claude or user. Effect varies by event |
| Other | Non-blocking error; transcript shows `<hook name> hook error` + first line of stderr |

**Key:** Exit 1 is non-blocking — use exit 2 to enforce policy. Exception: `WorktreeCreate` treats any non-zero exit as failure.

### JSON output fields (universal)

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops entirely. Overrides all event-specific decisions |
| `stopReason` | none | Shown to user when `continue: false` |
| `suppressOutput` | `false` | Omits stdout from debug log |
| `systemMessage` | none | Warning shown to user |

### Decision control by event

| Events | Decision pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code 2 or `continue: false` | — |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput`, `additionalContext` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` |
| `WorktreeCreate` | Path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `Notification`, `SubagentStart`, `SessionStart`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `CwdChanged`, `FileChanged`, `WorktreeRemove`, `StopFailure` | None | Side effects and logging only |

### PreToolUse permissionDecision values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skips permission prompt (deny rules still apply) |
| `"deny"` | Cancels tool call; `permissionDecisionReason` fed to Claude |
| `"ask"` | Shows permission prompt to user |
| `"defer"` | Non-interactive mode only (`-p`): exits with `stop_reason: "tool_deferred"` |

Multiple PreToolUse hooks: precedence is `deny > defer > ask > allow`.

### Common input fields (all events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSONL |
| `cwd` | Working directory when event fired |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, or `"bypassPermissions"` |
| `hook_event_name` | Name of the event that fired |

### Matcher patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all occurrences |
| Letters, digits, `_`, `\|` only | Exact string or `\|`-separated list |
| Contains other characters | JavaScript regex |

MCP tools follow `mcp__<server>__<tool>` naming. Use `mcp__memory__.*` to match all tools from a server.

### Environment variables in hooks

| Variable | Description |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | Project root; use in quotes for paths with spaces |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | File for persisting env vars to Bash commands (SessionStart, CwdChanged, FileChanged only) |

### Async hooks

Set `"async": true` on a `type: "command"` hook to run it in the background without blocking Claude. Async hooks cannot return decisions. After exit, `systemMessage` or `additionalContext` in stdout is delivered on the next conversation turn. Set `"asyncRewake": true` to wake Claude immediately on exit 2.

### Prompt and agent hook response schema

Both prompt and agent hooks must return:

```json
{"ok": true}
```

or:

```json
{"ok": false, "reason": "explanation fed back to Claude"}
```

### PermissionRequest updatedPermissions entry types

| `type` | Fields | Effect |
| :--- | :--- | :--- |
| `addRules` | `rules`, `behavior`, `destination` | Adds permission rules |
| `replaceRules` | `rules`, `behavior`, `destination` | Replaces all rules of given behavior |
| `removeRules` | `rules`, `behavior`, `destination` | Removes matching rules |
| `setMode` | `mode`, `destination` | Changes permission mode |
| `addDirectories` | `directories`, `destination` | Adds working directories |
| `removeDirectories` | `directories`, `destination` | Removes working directories |

`destination` values: `session`, `localSettings`, `projectSettings`, `userSettings`.

### CwdChanged and FileChanged: watchPaths output

Both events support returning `watchPaths` (array of absolute paths) to dynamically update the file watch list. Paths from the `matcher` config are always watched regardless.

### Common use cases

| Goal | Event | Pattern |
| :--- | :--- | :--- |
| Desktop notification when idle | `Notification` | matcher: `idle_prompt` |
| Auto-format after edits | `PostToolUse` | matcher: `Edit\|Write`; run formatter on `tool_input.file_path` |
| Block edits to protected files | `PreToolUse` | matcher: `Edit\|Write`; exit 2 with reason |
| Re-inject context after compaction | `SessionStart` | matcher: `compact`; print context to stdout |
| Audit config changes | `ConfigChange` | append to log file |
| Reload env on directory change | `CwdChanged` | write to `$CLAUDE_ENV_FILE` |
| Auto-approve specific permissions | `PermissionRequest` | matcher: tool name; return `{"behavior": "allow"}` |
| Block dangerous Bash commands | `PreToolUse` | matcher: `Bash`; `if: "Bash(rm *)"` |
| Enforce task naming conventions | `TaskCreated` | exit 2 on pattern mismatch |
| Verify tests pass before stop | `Stop` | `type: "agent"` hook runs test suite |

### Troubleshooting quick reference

| Symptom | Fix |
| :--- | :--- |
| Hook not firing | Check `/hooks` menu; verify matcher case; confirm correct event type |
| `PermissionRequest` hook not firing | Switch to `PreToolUse` (PermissionRequest skipped in `-p` mode) |
| Stop hook infinite loop | Check `stop_hook_active` field; exit 0 if `true` |
| JSON validation failed | Wrap `echo` in profile with `if [[ $- == *i* ]]; then ... fi` |
| Hook error in transcript | Test manually: pipe sample JSON to script; check exit code |
| Hooks not appearing in `/hooks` | Validate JSON (no trailing commas); check file path and watcher |

Debug hooks: `claude --debug-file /tmp/claude.log`, then monitor the log. Set `CLAUDE_CODE_DEBUG_LOG_LEVEL=verbose` for matcher-level detail.

### Security

Command hooks run with your full user permissions. Best practices:
- Validate and sanitize all input from stdin
- Always quote shell variables: `"$VAR"` not `$VAR`
- Block path traversal: check for `..` in file paths
- Use absolute paths via `"$CLAUDE_PROJECT_DIR"`
- Skip sensitive files like `.env`, `.git/`, keys

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — practical guide with common use cases, step-by-step examples, and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — full event schemas, JSON input/output formats, all hook types, async hooks, and security considerations

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
