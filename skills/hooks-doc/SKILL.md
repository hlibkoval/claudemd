---
name: hooks-doc
description: Complete official documentation for Claude Code hooks — hook events and lifecycle, configuration schema, matcher patterns, exit codes, JSON input/output formats, decision control per event, command/HTTP/MCP/prompt/agent hook types, async hooks, environment variables, and troubleshooting.
user-invocable: false
---

# Hooks Documentation

This skill provides the complete official documentation for Claude Code hooks.

## Quick Reference

### Hook Lifecycle Events

| Event | When it fires | Can block? |
| :--- | :--- | :--- |
| `SessionStart` | Session begins or resumes | No |
| `Setup` | `--init-only` or `--init`/`--maintenance` in `-p` mode | No |
| `InstructionsLoaded` | CLAUDE.md or rules file loaded into context | No |
| `UserPromptSubmit` | User submits a prompt | Yes |
| `UserPromptExpansion` | User-typed slash command expands into prompt | Yes |
| `PreToolUse` | Before a tool call executes | Yes |
| `PermissionRequest` | Permission dialog about to appear | Yes |
| `PermissionDenied` | Tool call denied by auto mode classifier | No (use `retry: true`) |
| `PostToolUse` | After a tool call succeeds | No (feedback only) |
| `PostToolUseFailure` | After a tool call fails | No |
| `PostToolBatch` | After parallel tool batch resolves | Yes |
| `Notification` | Claude Code sends a notification | No |
| `SubagentStart` / `SubagentStop` | Subagent spawned / finishes | No / Yes |
| `TaskCreated` / `TaskCompleted` | Task created / marked complete | Yes / Yes |
| `Stop` / `StopFailure` | Claude finishes responding / turn ends on API error | Yes / No |
| `TeammateIdle` | Agent team teammate about to go idle | Yes |
| `ConfigChange` | Configuration file changes during session | Yes |
| `CwdChanged` | Working directory changes | No |
| `FileChanged` | Watched file changes on disk | No |
| `WorktreeCreate` / `WorktreeRemove` | Worktree created / removed | Yes / No |
| `PreCompact` / `PostCompact` | Before / after context compaction | Yes / No |
| `Elicitation` / `ElicitationResult` | MCP server requests user input / user responds | Yes / Yes |
| `SessionEnd` | Session terminates | No |

### Configuration Structure

Hooks live in a JSON settings file under a `hooks` key. Three-level nesting:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### Hook Locations (Scope)

| Location | Scope | Shareable |
| :--- | :--- | :--- |
| `~/.claude/settings.json` | All projects | No |
| `.claude/settings.json` | Single project | Yes (commit to repo) |
| `.claude/settings.local.json` | Single project | No (gitignored) |
| Managed policy settings | Organization-wide | Yes (admin-controlled) |
| Plugin `hooks/hooks.json` | When plugin enabled | Yes |
| Skill or agent frontmatter | While component active | Yes |

Use `"disableAllHooks": true` in settings to disable all hooks. Use `/hooks` in Claude Code to browse configured hooks (read-only).

### Matcher Patterns

| Matcher value | Evaluated as |
| :--- | :--- |
| `"*"`, `""`, or omitted | Match all |
| Only letters, digits, `_`, `\|` | Exact string or pipe-separated list |
| Any other character | JavaScript regular expression |

Each event matches on a specific field:

| Event(s) | Matcher filters |
| :--- | :--- |
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied` | Tool name (`Bash`, `Edit\|Write`, `mcp__memory__.*`) |
| `SessionStart` | Session source: `startup`, `resume`, `clear`, `compact` |
| `Setup` | CLI flag: `init`, `maintenance` |
| `SessionEnd` | End reason: `clear`, `resume`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | Type: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`, `elicitation_complete`, `elicitation_response` |
| `SubagentStart`, `SubagentStop` | Agent type: `general-purpose`, `Explore`, `Plan`, custom names |
| `PreCompact`, `PostCompact` | Trigger: `manual`, `auto` |
| `ConfigChange` | Source: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `StopFailure` | Error type: `rate_limit`, `authentication_failed`, `billing_error`, `server_error`, `max_output_tokens`, `unknown` |
| `InstructionsLoaded` | Load reason: `session_start`, `nested_traversal`, `path_glob_match`, `include`, `compact` |
| `Elicitation`, `ElicitationResult` | MCP server name |
| `FileChanged` | Literal filenames to watch (`\|`-separated) |
| `UserPromptExpansion` | Command name |
| `UserPromptSubmit`, `PostToolBatch`, `Stop`, `TeammateIdle`, `TaskCreated`, `TaskCompleted`, `WorktreeCreate`, `WorktreeRemove`, `CwdChanged` | No matcher support (always fires) |

MCP tools follow `mcp__<server>__<tool>` naming. Use `mcp__memory__.*` to match all tools from a server.

### The `if` Field (Fine-grained Filtering)

Available on tool events only (`PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest`, `PermissionDenied`). Uses permission rule syntax. Hook only spawns when the tool call matches.

```json
{ "type": "command", "if": "Bash(git *)", "command": "./check-git-policy.sh" }
```

Supports patterns like `"Bash(git *)"`, `"Edit(*.ts)"`. For compound Bash commands, hook fires if any subcommand matches. On other events, a hook with `if` set never runs.

### Hook Handler Types

| Type | Description |
| :--- | :--- |
| `"command"` | Run a shell command. Receives JSON on stdin, communicates via exit code / stdout |
| `"http"` | POST event JSON to a URL. Response body uses same JSON output format |
| `"mcp_tool"` | Call a tool on a connected MCP server |
| `"prompt"` | Single-turn LLM evaluation returning `{"ok": true/false, "reason": "..."}` |
| `"agent"` | Subagent with tool access for multi-step verification (experimental) |

### Common Handler Fields

| Field | Required | Description |
| :--- | :--- | :--- |
| `type` | Yes | `"command"`, `"http"`, `"mcp_tool"`, `"prompt"`, or `"agent"` |
| `if` | No | Permission rule syntax filter (tool events only) |
| `timeout` | No | Seconds before cancel (default: 600 command, 30 prompt, 60 agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | Run once per session then remove (skill frontmatter only) |

### Command Hook Fields

| Field | Description |
| :--- | :--- |
| `command` | Shell command to execute |
| `async` | Run in background without blocking |
| `asyncRewake` | Run in background; wake Claude on exit 2 with stderr as system reminder |
| `shell` | `"bash"` (default) or `"powershell"` |

### HTTP Hook Fields

| Field | Description |
| :--- | :--- |
| `url` | URL to POST to |
| `headers` | Key-value pairs; values support `$VAR_NAME` interpolation |
| `allowedEnvVars` | List of env vars allowed to interpolate in headers |

### MCP Tool Hook Fields

| Field | Description |
| :--- | :--- |
| `server` | Name of connected MCP server |
| `tool` | Tool name on that server |
| `input` | Arguments; string values support `${path}` substitution from hook input |

### Prompt/Agent Hook Fields

| Field | Description |
| :--- | :--- |
| `prompt` | Prompt text. Use `$ARGUMENTS` as placeholder for hook input JSON |
| `model` | Model to use (defaults to fast model) |

### Exit Codes (Command Hooks)

| Exit code | Meaning |
| :--- | :--- |
| `0` | Success. JSON in stdout is processed. For `UserPromptSubmit`, `UserPromptExpansion`, `SessionStart`: stdout added to context |
| `2` | Blocking error. Stderr fed to Claude (or user). See table above for per-event behavior |
| Any other | Non-blocking error. Execution continues. First stderr line shown in transcript |

For `WorktreeCreate`, any non-zero exit code fails creation.

### JSON Output Fields (Universal)

Return on exit 0 by printing a JSON object to stdout:

| Field | Default | Description |
| :--- | :--- | :--- |
| `continue` | `true` | If `false`, Claude stops entirely. Takes precedence over event-specific decisions |
| `stopReason` | none | Message shown to user when `continue` is `false` |
| `suppressOutput` | `false` | Omit stdout from debug log |
| `systemMessage` | none | Warning message shown to user |

Context injection cap: 10,000 characters. Larger values are written to a file and replaced with a preview + path.

### Decision Control by Event

| Events | Pattern | Key fields |
| :--- | :--- | :--- |
| `UserPromptSubmit`, `UserPromptExpansion`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `Stop`, `SubagentStop`, `ConfigChange`, `PreCompact` | Top-level `decision` | `decision: "block"`, `reason` |
| `TeammateIdle`, `TaskCreated`, `TaskCompleted` | Exit code or `continue: false` | Exit 2 blocks; `{"continue": false}` stops entirely |
| `PreToolUse` | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`, `updatedInput` |
| `PermissionRequest` | `hookSpecificOutput` | `decision.behavior` (allow/deny), `updatedInput`, `updatedPermissions`, `message`, `interrupt` |
| `PermissionDenied` | `hookSpecificOutput` | `retry: true` to let model retry |
| `WorktreeCreate` | Path return | Command prints path on stdout; HTTP returns `hookSpecificOutput.worktreePath` |
| `Elicitation`, `ElicitationResult` | `hookSpecificOutput` | `action` (accept/decline/cancel), `content` |
| `WorktreeRemove`, `Notification`, `SessionEnd`, `PostCompact`, `InstructionsLoaded`, `StopFailure`, `CwdChanged`, `FileChanged` | None | Side-effects only |

### PreToolUse Decision Values

| Value | Effect |
| :--- | :--- |
| `"allow"` | Skip permission prompt. Deny/ask rules still apply |
| `"deny"` | Cancel tool call; `permissionDecisionReason` shown to Claude |
| `"ask"` | Show permission prompt to user |
| `"defer"` | Exit with `stop_reason: "tool_deferred"` for Agent SDK integration (non-interactive `-p` only) |

Multiple PreToolUse hooks: precedence is `deny` > `defer` > `ask` > `allow`.

### Common Input Fields (All Events)

| Field | Description |
| :--- | :--- |
| `session_id` | Current session identifier |
| `transcript_path` | Path to conversation JSON |
| `cwd` | Working directory when hook invoked |
| `permission_mode` | `"default"`, `"plan"`, `"acceptEdits"`, `"auto"`, `"dontAsk"`, `"bypassPermissions"` |
| `effort` | Object with `level` field: `"low"`, `"medium"`, `"high"`, `"xhigh"`, `"max"` |
| `hook_event_name` | Name of the event that fired |
| `agent_id` | Subagent identifier (inside subagent calls) |
| `agent_type` | Agent name (when using `--agent` or inside subagent) |

### Environment Variables

| Variable | Description |
| :--- | :--- |
| `$CLAUDE_PROJECT_DIR` | Project root; use to reference hook scripts portably |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin installation directory |
| `${CLAUDE_PLUGIN_DATA}` | Plugin persistent data directory |
| `$CLAUDE_ENV_FILE` | File path for persisting env vars to subsequent Bash commands (SessionStart, Setup, CwdChanged, FileChanged) |
| `$CLAUDE_EFFORT` | Active effort level string (`low`, `medium`, etc.) |
| `$CLAUDE_CODE_REMOTE` | `"true"` in remote web environments |

### Common Use Cases

| Goal | Event + matcher | Key technique |
| :--- | :--- | :--- |
| Format files after edit | `PostToolUse` + `Edit\|Write` | `jq -r '.tool_input.file_path' \| xargs prettier --write` |
| Block sensitive file edits | `PreToolUse` + `Edit\|Write` | Exit 2 or `permissionDecision: "deny"` |
| Desktop notification on idle | `Notification` + `idle_prompt` | `osascript` / `notify-send` / PowerShell |
| Re-inject context after compact | `SessionStart` + `compact` | Print text to stdout |
| Reload direnv on dir change | `CwdChanged` | `direnv export bash > "$CLAUDE_ENV_FILE"` |
| Auto-approve specific tools | `PermissionRequest` + tool name | `{"hookSpecificOutput": {"hookEventName": "PermissionRequest", "decision": {"behavior": "allow"}}}` |
| Audit config changes | `ConfigChange` | Append to log file |
| Stop infinite Stop hook loop | `Stop` | Check `stop_hook_active` field in input |

### Troubleshooting

| Issue | Fix |
| :--- | :--- |
| Hook not firing | `/hooks` to verify; check matcher case-sensitivity; `PermissionRequest` doesn't fire in `-p` mode |
| "hook error" in transcript | Test manually: `echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' \| ./hook.sh` |
| Script not found | Use absolute paths or `$CLAUDE_PROJECT_DIR`; check `chmod +x` |
| `/hooks` shows nothing | Validate JSON; check file location; restart session |
| Stop hook infinite loop | Parse `stop_hook_active` from stdin; exit 0 if true |
| JSON validation failed | Shell profile has unconditional `echo` — wrap in `if [[ $- == *i* ]]; then ... fi` |

Debug: `claude --debug-file /tmp/claude.log` then `tail -f /tmp/claude.log`. Or use `/debug` mid-session.

## Full Documentation

For the complete official documentation, see the reference files:

- [Automate workflows with hooks](references/claude-code-hooks-guide.md) — quickstart, common use cases with ready-to-use configs (notifications, auto-format, file protection, context injection, config auditing, direnv, auto-approve), how hooks work, prompt/agent/HTTP hook types, limitations and troubleshooting
- [Hooks reference](references/claude-code-hooks-reference.md) — complete hook lifecycle, configuration schema, matcher patterns, all handler types and fields, full JSON input/output spec, exit code behavior per event, decision control tables, and per-event input schemas for all 30+ events

## Sources

- Automate workflows with hooks: https://code.claude.com/docs/en/hooks-guide.md
- Hooks reference: https://code.claude.com/docs/en/hooks.md
